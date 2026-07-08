// ============================================================
// Supabase Edge Function: send-push-notification
// ============================================================
// Called via Database Webhook when a new row is inserted into
// the `notifications` table. Looks up the recipient's FCM
// token and sends a push notification via Firebase Cloud
// Messaging (HTTP v1 API).
//
// Environment variables (set via `supabase secrets set`):
//   - FCM_SERVER_KEY: Firebase Cloud Messaging server key (legacy)
//     OR
//   - FCM_SERVICE_ACCOUNT_JSON: Full Firebase service account JSON
//       (preferred for HTTP v1 API)
//   - FCM_PROJECT_ID: Firebase project ID (required for v1 API)
// ============================================================

import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.0";

interface NotificationPayload {
  type: "INSERT";
  table: string;
  schema: string;
  record: {
    id: string;
    user_id: string;
    title: string;
    body: string;
    type: string;
    is_read: boolean;
    related_id: string | null;
    related_type: string | null;
    created_at: string;
  };
  old_record: Record<string, unknown>;
}

interface FcmMessage {
  message: {
    token: string;
    notification: {
      title: string;
      body: string;
    };
    data?: Record<string, string>;
    android?: {
      priority: "high" | "normal";
      notification: {
        channel_id: string;
        sound: string;
        priority: "high" | "normal" | "max" | "low" | "min" | "default";
      };
    };
    apns?: {
      payload: {
        aps: {
          sound: string;
          badge: number;
          "content-available": number;
        };
      };
    };
  };
}

serve(async (req) => {
  // CORS headers
  if (req.method === "OPTIONS") {
    return new Response("ok", {
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "POST",
        "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
      },
    });
  }

  try {
    // 1. Parse the webhook payload
    const payload: NotificationPayload = await req.json();
    const { record } = payload;

    if (!record || !record.user_id) {
      console.error("Invalid payload: missing user_id");
      return new Response(
        JSON.stringify({ error: "Invalid payload: missing user_id" }),
        { status: 400, headers: { "Content-Type": "application/json" } }
      );
    }

    console.log(`Processing notification ${record.id} for user ${record.user_id}`);

    // 2. Look up the user's FCM token
    const supabaseUrl = Deno.env.get("SUPABASE_URL")!;
    const supabaseKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
    const supabase = createClient(supabaseUrl, supabaseKey);

    const { data: profile, error: profileError } = await supabase
      .from("profiles")
      .select("fcm_token, name, email")
      .eq("id", record.user_id)
      .single();

    if (profileError) {
      console.error("Failed to fetch profile:", profileError);
      return new Response(
        JSON.stringify({ error: "Failed to fetch profile" }),
        { status: 500, headers: { "Content-Type": "application/json" } }
      );
    }

    const fcmToken = profile?.fcm_token;
    if (!fcmToken) {
      console.log(`User ${record.user_id} has no FCM token — skipping push`);
      return new Response(
        JSON.stringify({ skipped: true, reason: "No FCM token" }),
        { status: 200, headers: { "Content-Type": "application/json" } }
      );
    }

    // 3. Determine notification channel based on type
    const channelId = getChannelId(record.type);
    const priority = record.type === "emergency" ? "high" : "normal";

    // 4. Build the FCM message
    const fcmMessage: FcmMessage = {
      message: {
        token: fcmToken,
        notification: {
          title: record.title,
          body: record.body,
        },
        data: {
          notification_id: record.id,
          type: record.type,
          related_id: record.related_id ?? "",
          related_type: record.related_type ?? "",
          route: getRouteForType(record.related_type, record.related_id),
        },
        android: {
          priority: priority as "high" | "normal",
          notification: {
            channel_id: channelId,
            sound: "default",
            priority: priority as "high" | "normal" | "default",
          },
        },
        apns: {
          payload: {
            aps: {
              sound: "default",
              badge: 1,
              "content-available": 1,
            },
          },
        },
      },
    };

    // 5. Send via FCM HTTP v1 API
    const fcmResponse = await sendFcmV1(fcmMessage);
    console.log(`Push notification sent successfully: ${fcmResponse}`);

    return new Response(
      JSON.stringify({ success: true, notification_id: record.id }),
      { status: 200, headers: { "Content-Type": "application/json" } }
    );
  } catch (error) {
    console.error("Unexpected error:", error);
    return new Response(
      JSON.stringify({ error: "Internal server error", details: error.message }),
      { status: 500, headers: { "Content-Type": "application/json" } }
    );
  }
});

function getChannelId(type: string): string {
  switch (type) {
    case "emergency":
      return "emergency_alerts";
    case "reminder":
      return "reminders";
    case "announcement":
      return "announcements";
    default:
      return "general";
  }
}

function getRouteForType(relatedType: string | null, relatedId: string | null): string {
  if (!relatedType || !relatedId) return "/notifications";
  switch (relatedType) {
    case "blood_request":
      return `/requests/${relatedId}`;
    case "hospital":
      return "/hospitals";
    case "blood_bank":
      return "/blood-banks";
    case "announcement":
      return "/notifications";
    default:
      return "/notifications";
  }
}

async function sendFcmV1(message: FcmMessage): Promise<string> {
  const serviceAccountJson = Deno.env.get("FCM_SERVICE_ACCOUNT_JSON");
  const serverKey = Deno.env.get("FCM_SERVER_KEY");

  if (serviceAccountJson) {
    // Use HTTP v1 API with OAuth2 (preferred)
    return await sendFcmV1WithOAuth(message, serviceAccountJson);
  } else if (serverKey) {
    // Use legacy HTTP API
    return await sendFcmLegacy(message, serverKey);
  } else {
    throw new Error(
      "No FCM credentials configured. Set FCM_SERVICE_ACCOUNT_JSON or FCM_SERVER_KEY."
    );
  }
}

async function sendFcmV1WithOAuth(
  message: FcmMessage,
  serviceAccountJson: string
): Promise<string> {
  const serviceAccount = JSON.parse(serviceAccountJson);
  const projectId = serviceAccount.project_id;

  // Get OAuth2 access token using service account
  const token = await getAccessTokenWithServiceAccount(serviceAccount);

  const response = await fetch(
    `https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`,
    {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${token}`,
      },
      body: JSON.stringify(message),
    }
  );

  if (!response.ok) {
    const errorText = await response.text();
    throw new Error(`FCM v1 API error: ${response.status} - ${errorText}`);
  }

  return await response.text();
}

async function sendFcmLegacy(
  message: FcmMessage,
  serverKey: string
): Promise<string> {
  // Convert to legacy format
  const legacyPayload = {
    to: message.message.token,
    notification: message.message.notification,
    data: message.message.data,
    android: {
      priority: message.message.android?.priority,
      notification: {
        channel_id: message.message.android?.notification?.channel_id,
        sound: message.message.android?.notification?.sound,
      },
    },
    apns: message.message.apns,
  };

  const response = await fetch("https://fcm.googleapis.com/fcm/send", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Authorization: `key=${serverKey}`,
    },
    body: JSON.stringify(legacyPayload),
  });

  if (!response.ok) {
    const errorText = await response.text();
    throw new Error(`FCM legacy API error: ${response.status} - ${errorText}`);
  }

  return await response.text();
}

async function getAccessTokenWithServiceAccount(
  serviceAccount: Record<string, string>
): Promise<string> {
  // JWT header
  const header = {
    alg: "RS256",
    typ: "JWT",
  };

  const now = Math.floor(Date.now() / 1000);
  const claims = {
    iss: serviceAccount.client_email,
    scope: "https://www.googleapis.com/auth/firebase.messaging",
    aud: "https://oauth2.googleapis.com/token",
    exp: now + 3600,
    iat: now,
  };

  // Base64url encode for JSON objects
  const base64url = (obj: Record<string, unknown>) =>
    btoa(JSON.stringify(obj))
      .replace(/=/g, "")
      .replace(/\+/g, "-")
      .replace(/\//g, "_");

  // Base64url encode raw bytes (for signature)
  const base64urlBytes = (bytes: Uint8Array) => {
    let binary = "";
    for (let i = 0; i < bytes.length; i++) {
      binary += String.fromCharCode(bytes[i]);
    }
    return btoa(binary)
      .replace(/=/g, "")
      .replace(/\+/g, "-")
      .replace(/\//g, "_");
  };

  const signatureInput = `${base64url(header)}.${base64url(claims)}`;

  // Convert PEM to CryptoKey
  const privateKey = serviceAccount.private_key;
  const pemHeader = "-----BEGIN PRIVATE KEY-----\n";
  const pemFooter = "\n-----END PRIVATE KEY-----";
  const pemContents = privateKey
    .replace(pemHeader, "")
    .replace(pemFooter, "")
    .replace(/\n/g, "");
  const binaryDer = Uint8Array.from(atob(pemContents), (c) => c.charCodeAt(0));

  const key = await crypto.subtle.importKey(
    "pkcs8",
    binaryDer.buffer,
    { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
    false,
    ["sign"]
  );

  const signature = await crypto.subtle.sign(
    { name: "RSASSA-PKCS1-v1_5" },
    key,
    new TextEncoder().encode(signatureInput)
  );

  // Encode the raw signature bytes directly (not wrapped in JSON)
  const signatureBytes = new Uint8Array(signature);
  const jwt = `${signatureInput}.${base64urlBytes(signatureBytes)}`;

  // Exchange JWT for access token
  const tokenResponse = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion: jwt,
    }),
  });

  if (!tokenResponse.ok) {
    const errorText = await tokenResponse.text();
    throw new Error(`OAuth2 token error: ${tokenResponse.status} - ${errorText}`);
  }

  const tokenData = await tokenResponse.json();
  return tokenData.access_token;
}

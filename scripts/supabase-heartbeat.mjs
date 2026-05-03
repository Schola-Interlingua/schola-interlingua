const SUPABASE_TABLE = "progress";

const url = process.env.SUPABASE_URL;
const anonKey = process.env.SUPABASE_ANON_KEY;

if (!url || !anonKey) {
  console.error("Missing required Supabase heartbeat environment variables.");
  process.exit(1);
}

const baseUrl = url.replace(/\/+$/, "");
// Read-only heartbeat to help prevent Supabase Free inactivity pauses.
const endpoint = `${baseUrl}/rest/v1/${SUPABASE_TABLE}?select=user_id&limit=1`;

try {
  const response = await fetch(endpoint, {
    method: "GET",
    headers: {
      apikey: anonKey,
      Authorization: `Bearer ${anonKey}`,
      Accept: "application/json",
    },
  });

  if (!response.ok) {
    console.error(`Supabase heartbeat failed with HTTP ${response.status}.`);
    process.exit(1);
  }

  console.log("Supabase heartbeat succeeded.");
} catch (error) {
  console.error("Supabase heartbeat failed to connect.");
  process.exit(1);
}

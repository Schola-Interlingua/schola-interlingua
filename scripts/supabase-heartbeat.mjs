const SUPABASE_TABLE = "heartbeat";
const HEARTBEAT_ID = "supabase-free-keepalive";

const url = process.env.SUPABASE_URL;
const adminKey =
  process.env.SUPABASE_SECRET_KEY || process.env.SUPABASE_SERVICE_ROLE_KEY;

if (!url || !adminKey) {
  console.error("Missing required Supabase heartbeat environment variables.");
  process.exit(1);
}

const baseUrl = url.replace(/\/+$/, "");
// Minimal write heartbeat to help prevent Supabase Free inactivity pauses.
const endpoint = `${baseUrl}/rest/v1/${SUPABASE_TABLE}?on_conflict=id`;

try {
  const response = await fetch(endpoint, {
    method: "POST",
    headers: {
      apikey: adminKey,
      Authorization: `Bearer ${adminKey}`,
      Accept: "application/json",
      "Content-Type": "application/json",
      Prefer: "resolution=merge-duplicates,return=minimal",
      "User-Agent": "schola-interlingua-supabase-heartbeat",
    },
    body: JSON.stringify({
      id: HEARTBEAT_ID,
      last_seen_at: new Date().toISOString(),
      updated_by: "github-actions",
    }),
    signal: AbortSignal.timeout(15000),
  });

  if (!response.ok) {
    console.error(`Supabase heartbeat failed with HTTP ${response.status}.`);
    process.exit(1);
  }

  console.log(`Supabase heartbeat succeeded for ${SUPABASE_TABLE}.`);
} catch (error) {
  console.error("Supabase heartbeat failed to connect.");
  process.exit(1);
}

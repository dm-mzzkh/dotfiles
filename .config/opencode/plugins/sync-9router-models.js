import { readFileSync, writeFileSync, renameSync } from "node:fs";
import { join } from "node:path";
import { homedir, tmpdir } from "node:os";

// ponytail: written as standalone config file; load via OPENCODE_CONFIG env var
const MODELS_PATH = join(homedir(), ".config", "opencode", "9router.json");
// ponytail: duplicated from opencode.json provider options; move to env if it rots
const BASE_URL = "http://stolas:20128/v1";
const API_KEY = process.env["9ROUTER_API_KEY"];

function readModelsFile() {
  try {
    const parsed = JSON.parse(readFileSync(MODELS_PATH, "utf-8"));
    return parsed.provider?.["9router"]?.models || null;
  } catch {
    return null;
  }
}

async function fetchModels(baseURL, apiKey) {
  const url = baseURL.replace(/\/v1\/?$/, "") + "/v1/models";
  const res = await fetch(url, {
    headers: { Authorization: `Bearer ${apiKey}` },
    signal: AbortSignal.timeout(5000),
  });
  if (!res.ok) return null;
  const data = await res.json();
  return data.data || [];
}

function buildModelsEntry(model) {
  const caps = model.capabilities || {};
  const entry = { name: model.id.split("/").pop() };
  if (caps.reasoning) entry.reasoning = true;
  const limit = {};
  if (caps.contextWindow) limit.context = caps.contextWindow;
  if (caps.maxOutput) limit.output = caps.maxOutput;
  if (Object.keys(limit).length) entry.limit = limit;
  return entry;
}

function modelsEqual(existing, remote) {
  const existingIds = Object.keys(existing || {}).sort();
  const remoteIds = remote.map((m) => m.id).sort();
  return (
    existingIds.length === remoteIds.length &&
    existingIds.every((id, i) => id === remoteIds[i])
  );
}

async function sync() {
  try {
    const models = await fetchModels(BASE_URL, API_KEY);
    if (!models || models.length === 0) return;

    const existing = readModelsFile();
    if (existing && modelsEqual(existing, models)) return;

    const remoteModels = {};
    for (const m of models) remoteModels[m.id] = buildModelsEntry(m);
    const out = { $schema: "https://opencode.ai/config.json", provider: { "9router": { models: remoteModels } } };
    const tmp = join(tmpdir(), `opencode-sync-${Date.now()}.json`);
    writeFileSync(tmp, JSON.stringify(out, null, 2) + "\n");
    renameSync(tmp, MODELS_PATH);
  } catch (e) {
    console.error("sync-9router-models:", e);
  }
}

export default async () => {
  return {
    event: async ({ event }) => {
      if (event.type === "server.connected") await sync();
    },
  };
};

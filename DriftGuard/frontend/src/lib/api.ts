const API = "/api/v1";

export type TokenResponse = {
  access_token: string;
  token_type: string;
  role: string;
  email: string;
  full_name: string;
};

function authHeaders(): HeadersInit {
  const token = localStorage.getItem("dg_token");
  return token
    ? { Authorization: `Bearer ${token}`, "Content-Type": "application/json" }
    : { "Content-Type": "application/json" };
}

async function request<T>(path: string, init?: RequestInit): Promise<T> {
  const res = await fetch(`${API}${path}`, {
    ...init,
    headers: { ...authHeaders(), ...(init?.headers || {}) },
  });
  if (res.status === 401) {
    localStorage.removeItem("dg_token");
    localStorage.removeItem("dg_user");
    if (!window.location.pathname.startsWith("/login") && !window.location.pathname.startsWith("/")) {
      window.location.href = "/login";
    }
  }
  if (!res.ok) {
    const text = await res.text();
    throw new Error(text || res.statusText);
  }
  if (res.status === 204) return undefined as T;
  return res.json();
}

export const api = {
  login: (email: string, password: string) =>
    request<TokenResponse>("/auth/login/json", {
      method: "POST",
      body: JSON.stringify({ email, password }),
    }),
  me: () => request<any>("/auth/me"),
  dashboard: () => request<any>("/dashboard/stats"),
  systems: () => request<any[]>("/systems"),
  system: (id: number) => request<any>(`/systems/${id}`),
  drifts: (params?: Record<string, string>) => {
    const q = params ? "?" + new URLSearchParams(params).toString() : "";
    return request<any[]>(`/drifts${q}`);
  },
  drift: (id: number) => request<any>(`/drifts/${id}`),
  updateDrift: (id: number, status: string) =>
    request<any>(`/drifts/${id}`, { method: "PATCH", body: JSON.stringify({ status }) }),
  remediations: () => request<any[]>("/remediations"),
  createRemediation: (drift_id: number, dry_run = true) =>
    request<any>("/remediations", {
      method: "POST",
      body: JSON.stringify({ drift_id, dry_run }),
    }),
  decideRemediation: (id: number, approve: boolean, notes?: string) =>
    request<any>(`/remediations/${id}/decide`, {
      method: "POST",
      body: JSON.stringify({ approve, notes }),
    }),
  applyRemediation: (id: number) =>
    request<any>(`/remediations/${id}/apply`, { method: "POST" }),
  desiredStates: () => request<any[]>("/desired-states"),
  settings: () => request<any[]>("/settings"),
  updateSetting: (key: string, value: unknown) =>
    request<any>(`/settings/${key}`, { method: "PATCH", body: JSON.stringify({ value }) }),
  audit: () => request<any[]>("/audit"),
  collect: (system_ids?: number[]) =>
    request<any>("/collect/run", {
      method: "POST",
      body: JSON.stringify({ system_ids: system_ids ?? null }),
    }),
  collectOne: (id: number) => request<any>(`/collect/systems/${id}`, { method: "POST" }),
};

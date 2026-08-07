import { Navigate, Outlet, Route, Routes } from "react-router-dom";
import { AppShell } from "@/components/layout/AppShell";
import { LandingPage } from "@/pages/LandingPage";
import { LoginPage } from "@/pages/LoginPage";
import { DashboardPage } from "@/pages/DashboardPage";
import { SystemsPage } from "@/pages/SystemsPage";
import { DriftsPage } from "@/pages/DriftsPage";
import { DriftDetailPage } from "@/pages/DriftDetailPage";
import { RemediationsPage } from "@/pages/RemediationsPage";
import { DesiredStatePage } from "@/pages/DesiredStatePage";
import { AuditPage } from "@/pages/AuditPage";
import { SettingsPage } from "@/pages/SettingsPage";

function RequireAuth() {
  if (!localStorage.getItem("dg_token")) {
    return <Navigate to="/login" replace />;
  }
  return (
    <AppShell>
      <Outlet />
    </AppShell>
  );
}

export default function App() {
  return (
    <Routes>
      <Route path="/" element={<LandingPage />} />
      <Route path="/login" element={<LoginPage />} />
      <Route path="/app" element={<RequireAuth />}>
        <Route index element={<DashboardPage />} />
        <Route path="systems" element={<SystemsPage />} />
        <Route path="drifts" element={<DriftsPage />} />
        <Route path="drifts/:id" element={<DriftDetailPage />} />
        <Route path="remediations" element={<RemediationsPage />} />
        <Route path="desired-state" element={<DesiredStatePage />} />
        <Route path="audit" element={<AuditPage />} />
        <Route path="settings" element={<SettingsPage />} />
      </Route>
      <Route path="*" element={<Navigate to="/" replace />} />
    </Routes>
  );
}

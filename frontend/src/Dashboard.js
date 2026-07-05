import React, { useState, useEffect } from 'react';

export default function SentinelDashboard() {
  const [metrics, setMetrics] = useState({ uptime: "DOWN", service: "Connecting...", sla_target: 0 });

  useEffect(() => {
    const fetchSystemMetrics = () => {
      fetch('http://localhost:8085/api/v1/availability')
        .then(res => res.json())
        .then(data => {
          setMetrics(data);
        })
        .catch(err => {
          console.error("Telemetry channel link failed:", err);
          setMetrics({ uptime: "DOWN", service: "sentinel-flux-core", sla_target: 99.9 });
        });
    };

    fetchSystemMetrics();
    const interval = setInterval(fetchSystemMetrics, 3000);
    return () => clearInterval(interval);
  }, []);

  return (
    <div style={{ padding: '40px', fontFamily: 'Segoe UI, sans-serif', backgroundColor: '#0f172a', color: '#f8fafc', minHeight: '100vh' }}>
      <h1 style={{ color: '#38bdf8', margin: '0 0 10px 0' }}>🛡️ Sentinel-Flux Control Center</h1>
      <p style={{ color: '#94a3b8', fontSize: '16px', margin: '0 0 40px 0' }}>Live System Level Indicators (SLIs) & Environment Parity Monitor</p>
      
      <div style={{ display: 'flex', gap: '25px' }}>
        <div style={{ background: '#1e293b', padding: '25px', borderRadius: '12px', border: '1px solid #334155', flex: 1 }}>
          <h3 style={{ color: '#94a3b8', margin: '0 0 15px 0', fontSize: '14px', textTransform: 'uppercase' }}>Engine Uptime Status</h3>
          <div style={{ fontSize: '28px', fontWeight: 'bold', color: metrics.uptime === "UP" ? '#10b981' : '#ef4444' }}>
            ● {metrics.uptime}
          </div>
          <p style={{ margin: '15px 0 0 0', fontSize: '13px', color: '#64748b' }}>Target Service: {metrics.service}</p>
        </div>

        <div style={{ background: '#1e293b', padding: '25px', borderRadius: '12px', border: '1px solid #334155', flex: 1 }}>
          <h3 style={{ color: '#94a3b8', margin: '0 0 15px 0', fontSize: '14px', textTransform: 'uppercase' }}>SLO Compliance Target</h3>
          <div style={{ fontSize: '36px', fontWeight: 'bold', color: '#38bdf8' }}>
            {metrics.sla_target}%
          </div>
          <p style={{ margin: '10px 0 0 0', fontSize: '13px', color: '#64748b' }}>SRE Operational Guardrail Limit</p>
        </div>
      </div>
    </div>
  );
}
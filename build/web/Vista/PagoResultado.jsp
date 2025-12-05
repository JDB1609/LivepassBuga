<%@ page contentType="text/html; charset=UTF-8" %>
<%
  String ctx    = request.getContextPath();
  String status = request.getParameter("status");
  String ref    = request.getParameter("ref");
  String method = request.getParameter("method");
  String eventId= request.getParameter("eventId");
  String qty    = request.getParameter("qty");
  String amount = request.getParameter("amount");
  String reason = request.getParameter("reason");

  boolean ok = "SUCCESS".equalsIgnoreCase(status);
%>
<!DOCTYPE html>
<html lang="es">
<head>
  <title>Resultado del pago</title>
  <style>
    body{font-family:system-ui,-apple-system,Segoe UI,Roboto;color:#eee;background:#0b0e16;margin:0}
    .wrap{max-width:680px;margin:40px auto;padding:24px;border-radius:18px;background:#141a26;border:1px solid rgba(255,255,255,.1)}
    .ok{color:#34d399} .fail{color:#fda4af}
    .btn{padding:.8rem 1.2rem;border-radius:12px;border:1px solid rgba(255,255,255,.25);color:#fff;background:transparent;text-decoration:none}
    .btn.primary{background:#01c7b8;border-color:#01c7b8;color:#04131b;font-weight:800}
    .row{display:grid;grid-template-columns:1fr 1fr;gap:8px}
    .box{padding:10px;border-radius:12px;background:#0f1420;border:1px solid rgba(255,255,255,.08)}
    .small{opacity:.75}
  </style>
</head>
<body>
  <div class="wrap">
    <h2><%= ok ? "✅ Pago aprobado" : "❌ Pago rechazado" %></h2>
    <p class="<%= ok? "ok":"fail" %>"><b><%= (ok ? "Transacción exitosa." : (reason!=null?reason:"Transacción no aprobada.")) %></b></p>

    <div class="row" style="margin-top:12px">
      <div class="box"><div class="small">Referencia</div><div><b><%= ref %></b></div></div>
      <div class="box"><div class="small">Método</div><div><b><%= method %></b></div></div>
      <div class="box"><div class="small">Evento</div><div><b>#<%= eventId %></b></div></div>
      <div class="box"><div class="small">Entradas</div><div><b><%= qty %></b></div></div>
      <div class="box"><div class="small">Monto</div><div><b><%= amount %></b></div></div>
      <div class="box"><div class="small">Estado</div><div><b><%= status %></b></div></div>
    </div>

    <div style="display:flex;gap:10px;margin-top:16px">
      <% if (ok) { %>
        <a class="btn primary" href="<%= ctx %>/Vista/MisTickets.jsp">Ver mis tickets</a>
      <% } %>
      <a class="btn" href="<%= ctx %>/Vista/PaginaPrincipal.jsp">Volver al inicio</a>
    </div>
  </div>
</body>
</html>

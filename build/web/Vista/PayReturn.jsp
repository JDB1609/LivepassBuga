<%@ page contentType="text/html; charset=UTF-8" %>
<%
  String orderId = request.getParameter("orderId");
  String s = request.getParameter("s"); // approved/pending/rejected (sim)
%>
<!DOCTYPE html>
<html lang="es">
<head>
  <%@ include file="../Includes/head_base.jspf" %>
  <title>Resultado del pago</title>
</head>
<body class="text-white font-sans">
  <%@ include file="../Includes/nav_base.jspf" %>
  <main class="max-w-xl mx-auto px-5 py-12">
    <div class="glass ring rounded-2xl p-6">
      <h1 class="text-2xl font-extrabold mb-2">Resultado del pago</h1>
      <p class="text-white/70">Orden #<%= orderId %></p>
      <% if ("approved".equalsIgnoreCase(s)) { %>
        <div class="mt-4 p-3 rounded-lg bg-emerald-600/20 border border-emerald-400/40">¡Pago aprobado! Tus tickets están disponibles en “Mis tickets”.</div>
      <% } else if ("pending".equalsIgnoreCase(s)) { %>
        <div class="mt-4 p-3 rounded-lg bg-yellow-600/20 border border-yellow-400/40">Pago pendiente. Te notificaremos cuando se confirme.</div>
      <% } else if ("rejected".equalsIgnoreCase(s)) { %>
        <div class="mt-4 p-3 rounded-lg bg-pink-600/20 border border-pink-400/40">Pago rechazado. Intenta nuevamente.</div>
      <% } %>

      <div class="mt-5 flex gap-3">
        <a class="btn-primary ripple" href="MisTickets.jsp">Mis tickets</a>
        <a class="px-4 py-2 rounded-xl border border-white/15 hover:border-white/30" href="PaginaPrincipal.jsp">Inicio</a>
      </div>
    </div>
  </main>
</body>
</html>

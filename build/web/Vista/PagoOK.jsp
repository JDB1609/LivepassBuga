<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.util.*" %>
<%
  Integer uid = (Integer) session.getAttribute("userId");
  if (uid == null) { response.sendRedirect(request.getContextPath()+"/Vista/Login.jsp"); return; }

  List<String> codes = (List<String>) session.getAttribute("lastCodes");
  if (codes == null) codes = java.util.Collections.emptyList();
  session.removeAttribute("lastCodes"); // flash one-time
%>
<!DOCTYPE html>
<html lang="es">
<head>
  <%@ include file="../Includes/head_base.jspf" %>
  <title>Pago exitoso</title>
</head>
<body class="text-white font-sans">
  <%@ include file="../Includes/nav_base.jspf" %>

  <main class="max-w-3xl mx-auto px-5 py-10">
    <div class="glass ring rounded-2xl p-6">
      <h1 class="text-2xl font-extrabold text-emerald-300">¡Pago confirmado!</h1>
      <p class="text-white/70 mt-2">Tus tickets fueron generados correctamente.</p>

      <h2 class="font-bold mt-5 mb-2">Códigos de ticket</h2>
      <ul class="list-disc pl-6 space-y-1">
        <% if (codes.isEmpty()) { %>
          <li class="text-white/70">Se generaron los tickets, pero no hay códigos para mostrar.</li>
        <% } else { for (String c : codes) { %>
          <li><code><%= c %></code></li>
        <% } } %>
      </ul>

      <div class="mt-6 flex gap-3">
        <a class="btn-primary ripple" href="<%= request.getContextPath() %>/Vista/MisTickets.jsp">Ver mis tickets</a>
        <a class="px-4 py-2 rounded-xl border border-white/15 hover:border-white/30"
           href="<%= request.getContextPath() %>/Vista/PaginaPrincipal.jsp">Seguir explorando</a>
      </div>
    </div>
  </main>
</body>
</html>

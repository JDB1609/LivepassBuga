<%@ page contentType="text/html; charset=UTF-8" %>
<%
  Integer uid = (Integer) session.getAttribute("userId");
  if (uid == null) { response.sendRedirect(request.getContextPath()+"/Vista/Login.jsp"); return; }

  String reason = request.getParameter("reason");
  String msg = "Ocurrió un error procesando el pago.";
  if ("card".equals(reason))  msg = "La tarjeta fue rechazada por el simulador. Prueba con otro número.";
  if ("token".equals(reason)) msg = "Sesión inválida o token expirado. Intenta nuevamente desde el checkout.";
  if ("db".equals(reason))    msg = "No fue posible generar los tickets. Intenta nuevamente.";
%>
<!DOCTYPE html>
<html lang="es">
<head>
  <%@ include file="../Includes/head_base.jspf" %>
  <title>Error de pago</title>
</head>
<body class="text-white font-sans">
  <%@ include file="../Includes/nav_base.jspf" %>

  <main class="max-w-3xl mx-auto px-5 py-10">
    <div class="glass ring rounded-2xl p-6">
      <h1 class="text-2xl font-extrabold text-pink-300">Pago no procesado</h1>
      <p class="text-white/70 mt-2"><%= msg %></p>

      <div class="mt-6 flex gap-3">
        <a class="btn-primary ripple" href="<%= request.getContextPath() %>/Vista/PaginaPrincipal.jsp">Volver al inicio</a>
        <a class="px-4 py-2 rounded-xl border border-white/15 hover:border-white/30"
           href="javascript:history.back()">Volver</a>
      </div>
    </div>
  </main>
</body>
</html>

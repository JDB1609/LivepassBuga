<%@ page contentType="text/html; charset=UTF-8" %>
<%
  String orderId = request.getParameter("orderId");
  String amount  = request.getParameter("amount");
  String back    = request.getParameter("return"); // opcional
%>
<!DOCTYPE html>
<html lang="es">
<head>
  <%@ include file="../Includes/head_base.jspf" %>
  <title>Pasarela de pago (simulada)</title>
</head>
<body class="text-white font-sans">
  <main class="max-w-md mx-auto px-5 py-14">
    <div class="glass ring rounded-2xl p-6 text-center">
      <h1 class="text-2xl font-extrabold">Pasarela de pago (Simulada)</h1>
      <p class="text-white/70 mt-2">Orden #<%= orderId %></p>
      <p class="text-xl font-bold mt-3">Total: COP <%= amount %></p>

      <form class="space-y-3 mt-6" action="<%= request.getContextPath() %>/Control/ct_pay_sim_result.jsp" method="post">
        <input type="hidden" name="orderId" value="<%= orderId %>"/>
        <input type="hidden" name="return"  value="<%= back!=null?back:"" %>"/>

        <button name="result" value="approved" class="btn-primary ripple w-full">Aprobar pago</button>
        <button name="result" value="pending" class="w-full px-4 py-3 rounded-xl border border-white/15 hover:border-white/30">Dejar pendiente</button>
        <button name="result" value="rejected" class="w-full px-4 py-3 rounded-xl border border-pink-400/40 text-pink-200 hover:border-pink-300">Rechazar</button>
      </form>
    </div>
  </main>
</body>
</html>

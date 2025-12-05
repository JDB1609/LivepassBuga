<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="dao.TicketDAO, utils.Ticket" %>
<%
  Integer uid = (Integer) session.getAttribute("userId");
  if (uid == null) { response.sendRedirect(request.getContextPath()+"/Vista/Login.jsp"); return; }

  int tid = 0; try { tid = Integer.parseInt(request.getParameter("tid")); } catch(Exception ignore){}
  TicketDAO tdao = new TicketDAO();
  Ticket t = tdao.findForUser(tid, uid).orElse(null);
  if (t == null) { response.sendRedirect(request.getContextPath()+"/Vista/MisTickets.jsp"); return; }

  String msg = request.getParameter("msg");
%>
<!DOCTYPE html>
<html lang="es">
<head>
  <%@ include file="../Includes/head_base.jspf" %>
  <title>Transferir ticket</title>
</head>
<body class="text-white font-sans">
  <%@ include file="../Includes/nav_base.jspf" %>

  <main class="max-w-3xl mx-auto px-5 py-10">
    <div class="glass ring rounded-2xl p-6">
      <h1 class="text-2xl font-extrabold mb-1">Transferir ticket</h1>
      <p class="text-white/70 mb-4"><%= t.getEventTitle() %> — <%= t.getDate() %></p>

      <% if (msg != null) { %>
        <div class="mb-4 p-3 rounded-lg bg-pink-600/20 border border-pink-400/40"><%= msg %></div>
      <% } %>

      <form action="<%= request.getContextPath() %>/Control/ct_transfer_ticket.jsp" method="post" class="space-y-3">
        <input type="hidden" name="tid" value="<%= t.getId() %>">
        <label class="block text-white/80">Email del destinatario</label>
        <input type="email" name="toEmail" required
               class="w-full px-4 py-3 rounded-xl bg-white/5 ring focus:outline-none focus:ring-2 focus:ring-primary"
               placeholder="persona@dominio.com">
        <p class="text-white/60 text-sm">El destinatario debe tener una cuenta registrada.</p>
        <div class="mt-3 flex gap-2">
          <button class="btn-primary ripple" type="submit">Transferir</button>
          <a class="px-4 py-2 rounded-xl border border-white/15 hover:border-white/30"
             href="<%= request.getContextPath() %>/Vista/MisTickets.jsp">Cancelar</a>
        </div>
      </form>
    </div>
  </main>
</body>
</html>

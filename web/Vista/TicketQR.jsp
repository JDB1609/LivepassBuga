<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="dao.TicketDAO, utils.Ticket, java.time.format.DateTimeFormatter" %>
<%
  Integer uid = (Integer) session.getAttribute("userId");
  if (uid == null) { response.sendRedirect(request.getContextPath()+"/Vista/Login.jsp"); return; }

  int tid = 0;
  try { tid = Integer.parseInt(request.getParameter("tid")); } catch(Exception ignore){}
  if (tid <= 0) { response.sendRedirect(request.getContextPath()+"/Vista/MisTickets.jsp"); return; }

  TicketDAO dao = new TicketDAO();
  java.util.Optional<utils.Ticket> opt = dao.findForUser(tid, uid);
  if (!opt.isPresent()) { response.sendRedirect(request.getContextPath()+"/Vista/MisTickets.jsp"); return; }
  utils.Ticket t = opt.get();

  DateTimeFormatter df = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
  String dateStr = (t.getEventDateTime()!=null) ? t.getEventDateTime().format(df) : (t.getDate()!=null ? t.getDate() : "");
%>
<!DOCTYPE html>
<html lang="es">
<head>
  <%@ include file="../Includes/head_base.jspf" %>
  <title>Ticket #<%= tid %> — QR</title>
</head>
<body class="text-white font-sans">
  <%@ include file="../Includes/nav_base.jspf" %>

  <main class="max-w-3xl mx-auto px-5 py-10">
    <article class="glass ring rounded-2xl p-6 grid md:grid-cols-2 gap-6">
      <div>
        <h1 class="text-2xl font-extrabold"><%= t.getEventTitle()!=null ? t.getEventTitle() : "Evento" %></h1>
        <p class="text-white/70 mt-1">📅 <%= dateStr %></p>
        <p class="text-white/70">📍 <%= t.getVenue()!=null ? t.getVenue() : "" %></p>
        <p class="text-white/70">🎟️ Entradas: <%= t.getQty() %></p>


        <div class="mt-6 flex gap-3">
          <a class="btn-primary ripple"
             href="<%= request.getContextPath() %>/Control/qr_image.jsp?tid=<%= tid %>&s=1024&dl=1">
             Descargar PNG
          </a>
          <a class="px-4 py-2 rounded-xl border border-white/15 hover:border-white/30"
             href="<%= request.getContextPath() %>/Vista/MisTickets.jsp">Volver</a>
        </div>
      </div>

      <div class="flex items-center justify-center">
        <img class="rounded-xl ring"
             alt="QR Ticket"
             src="<%= request.getContextPath() %>/Control/qr_image.jsp?tid=<%= tid %>&s=320">
      </div>
    </article>
  </main>

  <script>
    (function(){ document.querySelectorAll('.ripple').forEach(function(b){
      b.addEventListener('click',function(e){
        var r=this.getBoundingClientRect(),s=document.createElement('span'),z=Math.max(r.width,r.height);
        s.style.width=s.style.height=z+'px'; s.style.left=(e.clientX-r.left-z/2)+'px'; s.style.top=(e.clientY-r.top-z/2)+'px';
        this.appendChild(s); setTimeout(function(){s.remove();},600);
      });
    });})();
  </script>
</body>
</html>

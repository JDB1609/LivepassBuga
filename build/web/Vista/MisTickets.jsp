<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="utils.Ticket" %>
<%
  // ===== Guard: solo CLIENTE =====
  Integer _uid = (Integer) session.getAttribute("userId");
  if (_uid == null) { response.sendRedirect(request.getContextPath()+"/Vista/Login.jsp"); return; }
  String _role = (String) session.getAttribute("role");
  if (_role == null || !"CLIENTE".equalsIgnoreCase(_role)) { 
    response.sendRedirect(request.getContextPath()+"/Vista/DashboardOrganizador.jsp"); 
    return; 
  }
  String ctx = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="es">
<head>
  <%@ include file="../Includes/head_base.jspf" %>
  <title>Mis tickets — Livepass Buga</title>
  <style>
    /* micro-ajustes visuales del módulo */
    .pill{display:inline-flex;align-items:center;gap:.35rem;padding:.25rem .6rem;
      border-radius:999px;font-weight:800;font-size:.75rem;letter-spacing:.01em}
    .pill-ok{background:rgba(16,185,129,.18);color:#bbf7d0;border:1px solid rgba(16,185,129,.28)}
    .pill-used{background:rgba(255,255,255,.12);color:rgba(255,255,255,.85);border:1px solid rgba(255,255,255,.18)}
    .pill-refund{background:rgba(244,63,94,.18);color:#fecdd3;border:1px solid rgba(244,63,94,.28)}
    .card{position:relative}
    .card .actions{display:flex;flex-wrap:wrap;gap:.5rem}
    .toolbar-btn{padding:.6rem .9rem;border:1px solid rgba(255,255,255,.15);border-radius:12px}
    .toolbar-btn:hover{border-color:rgba(255,255,255,.30)}
    .tab-btn{padding:.5rem .9rem;border-radius:12px;border:1px solid rgba(255,255,255,.12)}
    .tab-btn.active{background:rgba(255,255,255,.12);border-color:rgba(255,255,255,.22)}
    .empty{border:1px dashed rgba(255,255,255,.18)}
  </style>
</head>
<body class="text-white font-sans">
  <%@ include file="../Includes/nav_base.jspf" %>

  <main class="max-w-6xl mx-auto px-5 py-10">
    <div class="flex flex-col gap-4 sm:flex-row sm:items-end sm:justify-between mb-6">
      <div>
        <h1 class="text-2xl font-extrabold">Mis tickets</h1>
        <p class="text-white/60">Consulta, descarga y transfiere tus entradas</p>
      </div>
      <div class="flex flex-wrap gap-2">
        <a href="<%= ctx %>/Vista/HomeCliente.jsp" class="toolbar-btn">🏠 Home</a>
        <a href="<%= ctx %>/Vista/ExplorarEventos.jsp" class="toolbar-btn">🎫 Explorar eventos</a>
        <form action="../Control/ct_mis_tickets.jsp" method="get" class="flex items-center gap-2">
          <input name="q" placeholder="Buscar evento..." class="px-4 py-2 rounded-xl bg-white/5 ring focus:outline-none focus:ring-2 focus:ring-primary" />
          <button class="btn-primary ripple" type="submit">Buscar</button>
        </form>
      </div>
    </div>

    <%-- Cargar datos --%>
    <jsp:include page="../Control/ct_mis_tickets.jsp" />

    <%
      List<Ticket> upcoming = (List<Ticket>) request.getAttribute("upcoming");
      List<Ticket> past     = (List<Ticket>) request.getAttribute("past");
      int upCount = (upcoming!=null? upcoming.size() : 0);
      int paCount = (past!=null? past.size() : 0);
      String refOk = request.getParameter("ref");
      String ok    = request.getParameter("ok");
    %>

    <% if ("1".equals(ok) && refOk!=null) { %>
      <div class="glass ring rounded-xl p-3 mb-4" style="border-color:rgba(0,209,178,.35); background:rgba(0,209,178,.10)">
        ✅ Compra registrada. Referencia: <b><%= refOk %></b>
      </div>
    <% } %>

    <!-- Tabs -->
    <div class="flex items-center gap-2 mb-5">
      <button id="tab-up"  class="tab-btn active">Próximos <span class="pill pill-ok" style="margin-left:.35rem"><%= upCount %></span></button>
      <button id="tab-past" class="tab-btn">Pasados  <span class="pill pill-used" style="margin-left:.35rem"><%= paCount %></span></button>
    </div>

    <!-- Próximos -->
    <section id="panel-up" class="grid sm:grid-cols-2 lg:grid-cols-3 gap-5">
      <%
        if (upCount > 0) {
          int i=0;
          for (Ticket t: upcoming) {
      %>
      <article class="card glass ring rounded-2xl p-5 animate-fadeUp" style="animation-delay:<%= (i++ * 0.06) %>s">
        <div class="flex items-center justify-between mb-2">
          <h3 class="font-bold text-lg leading-tight line-clamp-2"><%= t.getEventTitle() %></h3>
          <span class="pill pill-ok">VÁLIDO</span>
        </div>
        <p class="text-white/70">📅 <%= t.getDate() %></p>
        <p class="text-white/70">📍 <%= t.getVenue() %></p>
        <p class="text-white/60 text-sm mt-1">🎟️ Asiento: <%= (t.getSeat()!=null && !t.getSeat().isEmpty()) ? t.getSeat() : "General" %></p>
        <div class="actions mt-4">
          <a class="btn-primary ripple" href="TicketQR.jsp?tid=<%= t.getId() %>">Ver QR</a>
          <a class="px-4 py-2 rounded-lg border border-white/15 hover:border-white/30 font-bold transition"
             href="../Control/ct_ticket_pdf.jsp?tid=<%= t.getId() %>">Descargar PDF</a>
          <a class="px-4 py-2 rounded-lg border border-white/15 hover:border-white/30 font-bold transition"
             href="TransferirTicket.jsp?tid=<%= t.getId() %>">Transferir</a>
        </div>
      </article>
      <%  } } else { %>
      <div class="col-span-full glass ring rounded-2xl p-8 text-center text-white/70 empty">
        No tienes tickets próximos. ¿Buscas algo nuevo?
        <div class="mt-3">
          <a class="btn-primary ripple" href="<%= ctx %>/Vista/ExplorarEventos.jsp">Explorar eventos</a>
        </div>
      </div>
      <% } %>
    </section>

    <!-- Pasados -->
    <section id="panel-past" class="hidden grid sm:grid-cols-2 lg:grid-cols-3 gap-5">
      <%
        if (paCount > 0) {
          int j=0;
          for (Ticket t: past) {
            String st = String.valueOf(t.getStatus());
            String pillCls = "USADO".equalsIgnoreCase(st) ? "pill-used" :
                             "REEMBOLSADO".equalsIgnoreCase(st) ? "pill-refund" : "pill-used";
      %>
      <article class="card glass ring rounded-2xl p-5 animate-fadeUp" style="animation-delay:<%= (j++ * 0.06) %>s">
        <div class="flex items-center justify-between mb-2">
          <h3 class="font-bold text-lg leading-tight line-clamp-2"><%= t.getEventTitle() %></h3>
          <span class="pill <%= pillCls %>"><%= st %></span>
        </div>
        <p class="text-white/70">📅 <%= t.getDate() %></p>
        <p class="text-white/70">📍 <%= t.getVenue() %></p>
        <p class="text-white/60 text-sm mt-1">🎟️ Asiento: <%= (t.getSeat()!=null && !t.getSeat().isEmpty()) ? t.getSeat() : "General" %></p>
        <div class="actions mt-4">
          <span class="px-4 py-2 rounded-lg border border-white/15 text-white/50 cursor-not-allowed">Ver QR</span>
          <a class="px-4 py-2 rounded-lg border border-white/15 hover:border-white/30 font-bold transition"
             href="../Control/ct_ticket_pdf.jsp?tid=<%= t.getId() %>">Descargar PDF</a>
        </div>
      </article>
      <%  } } else { %>
      <div class="col-span-full glass ring rounded-2xl p-8 text-center text-white/70 empty">
        Aún no tienes tickets pasados.
      </div>
      <% } %>
    </section>
  </main>

  <script>
    // Tabs
    (function(){
      const upBtn=document.getElementById('tab-up');
      const paBtn=document.getElementById('tab-past');
      const upSec=document.getElementById('panel-up');
      const paSec=document.getElementById('panel-past');
      function sel(which){
        const up= (which==='up');
        upSec.classList.toggle('hidden', !up);
        paSec.classList.toggle('hidden',  up);
        upBtn.classList.toggle('active',  up);
        paBtn.classList.toggle('active', !up);
      }
      upBtn?.addEventListener('click', ()=>sel('up'));
      paBtn?.addEventListener('click', ()=>sel('past'));
    })();

    // Ripple
    (function(){ document.querySelectorAll('.ripple').forEach(b=>b.addEventListener('click',function(e){
      const r=this.getBoundingClientRect(),s=document.createElement('span'),z=Math.max(r.width,r.height);
      s.style.width=s.style.height=z+'px'; s.style.left=(e.clientX-r.left-z/2)+'px'; s.style.top=(e.clientY-r.top-z/2)+'px';
      this.appendChild(s); setTimeout(()=>s.remove(),600);
    }));})();
  </script>
</body>
</html>

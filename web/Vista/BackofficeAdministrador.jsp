<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.util.*" %>

<%
    Long uid  = (Long) session.getAttribute("adminId");
    String role  = (String) session.getAttribute("role");
    String name  = (String) session.getAttribute("adminNombre");

    if (uid == null) { response.sendRedirect(request.getContextPath()+"/Vista/Login.jsp"); return; }
    if (role == null || !"admin".equalsIgnoreCase(role)) {
        response.sendRedirect(request.getContextPath()+"/Vista/PaginaPrincipal.jsp"); return;
    }

    int totalUsuarios = 0;
    int totalOrganizadores = 0;
    int totalEventos = 0;
    int totalTickets = 0;
    int totalComisiones = 0;

    List<Map<String,String>> pendientes = new ArrayList<>();
    for(int i=1;i<=3;i++){
        Map<String,String> e = new HashMap<>();
        e.put("id", i+"");
        e.put("title", "Evento de prueba "+i);
        e.put("venue", "Lugar "+i);
        pendientes.add(e);
    }
%>

<!DOCTYPE html>
<html lang="es">
<head>
    <%@ include file="../Includes/head_base.jspf" %>
    <title>Panel — Administrador</title>

    <style>
      .metric {
        background: linear-gradient(180deg, rgba(255,255,255,.06), rgba(255,255,255,.04));
        border-radius: 18px;
        padding: 18px;
        box-shadow: 0 10px 40px rgba(0,0,0,.45), inset 0 1px 0 rgba(255,255,255,.04);
        transition: transform .15s;
      }
      .metric:hover { transform: translateY(-2px); }
      .k { font-size: 1.7rem; font-weight: 800; }

      .boton-morado, .boton-negro {
        border-radius: 12px;
        font-weight: 700;
        transition: .2s;
      }
      .boton-morado { background: #6c5ce7; color:white; }
      .boton-negro  { background: transparent; border:1px solid white; color:white; }

      .boton-morado:hover { filter: brightness(1.1); }
      .boton-negro:hover  { background: rgba(255,255,255,0.15); }

      /* BOTONES MÁS PEQUEÑOS */
      .boton-mini {
        padding: 8px 14px;
        font-size: 0.85rem;
      }
    </style>      
</head>

<body class="text-white font-sans bg-[#0b0e16]">

<header class="sticky top-0 z-30 backdrop-blur bg-[#0b0e16] border-b border-white/10">
  <div class="max-w-6xl mx-auto px-5 py-3 flex items-center justify-between">
    <a href="#" class="flex items-center gap-2 font-extrabold tracking-tight">
      <span class="inline-block w-3 h-3 rounded-sm" style="background:#00d1b2"></span> Livepass <span class="text-aqua">Buga</span>
    </a>

    <nav class="hidden sm:flex items-center gap-5 text-white/80">
      <a href="#" class="hover:text-white transition">Panel</a>
      <a href="#" class="hover:text-white transition">Administradores</a>
      <a href="#" class="hover:text-white transition">Clientes</a>
      <a href="#" class="hover:text-white transition">Organizadores</a>
      <a href="#" class="hover:text-white transition">Eventos</a>
      <a href="#" class="hover:text-white transition">Tickets</a>

      <a href="<%= request.getContextPath() %>/Control/ct_logout_admin.jsp"
         class="px-4 py-2 rounded-xl border border-white/15 hover:border-white/30">Salir</a>
    </nav>
  </div>
</header>

<main class="max-w-6xl mx-auto px-5 py-10">

  <div class="mb-6">
    <h1 class="text-3xl md:text-4xl font-extrabold">Hola, <%= name %></h1>
    <p class="text-white/70 mt-1">Panel de administrador.</p>
  </div>

  <!-- ======= BOTONES A LA DERECHA Y MÁS PEQUEÑOS ======= -->
  <section class="flex justify-end gap-3 mt-10">

    <a href="AprobacionEventos.jsp" class="boton-morado boton-mini">Aceptar / Rechazar</a>

    <a href="CrearAdministrador.jsp" class="boton-negro boton-mini">Crear Admin</a>

    <a href="#" class="boton-negro boton-mini">Responder PQRS</a>

  </section>

  <!-- ======= MÉTRICAS ======= -->
  <section class="grid md:grid-cols-5 gap-4 mt-8">
    <div class="metric"><div class="text-white/70">Usuarios</div>
      <div class="k"><%= totalUsuarios %></div></div>

    <div class="metric"><div class="text-white/70">Organizadores</div>
      <div class="k"><%= totalOrganizadores %></div></div>

    <div class="metric"><div class="text-white/70">Eventos</div>
      <div class="k"><%= totalEventos %></div></div>

    <div class="metric"><div class="text-white/70">Total Tickets</div>
      <div class="k"><%= totalTickets %></div></div>

    <div class="metric"><div class="text-white/70">Total comisiones (10%)</div>
      <div class="k">$<%= totalComisiones %></div></div>
  </section>

  <!-- ======= EVENTOS PENDIENTES ======= -->
  <section class="mt-14 glass rounded-2xl p-6 ring">
    <h2 class="text-xl font-bold mb-2">Eventos pendientes</h2>
    <p class="text-white/70 mb-4">Máximo 5 próximos eventos por aprobar</p>

    <% if (pendientes != null && !pendientes.isEmpty()) { %>
      <div class="space-y-4">
        <% for (Map<String,String> ev : pendientes) { %>
          <div class="p-4 rounded-xl bg-white/5 flex justify-between items-center">
            <div>
              <div class="font-bold"><%= ev.get("title") %></div>
              <div class="text-white/60 text-sm"><%= ev.get("venue") %></div>
            </div>

            <div class="flex gap-2">
              <a href="#" class="px-3 py-1 rounded bg-green-600">Aprobar</a>
              <a href="#" class="px-3 py-1 rounded bg-red-600">Rechazar</a>
              <a href="#" class="px-3 py-1 rounded bg-white/20">Ver más</a>
            </div>
          </div>
        <% } %>
      </div>

    <% } else { %>
      <div class="text-white/60">No hay eventos pendientes.</div>
    <% } %>
  </section>

</main>

</body>
</html>
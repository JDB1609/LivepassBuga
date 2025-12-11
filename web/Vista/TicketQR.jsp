<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="dao.TicketDAO, utils.Ticket, java.time.format.DateTimeFormatter" %>
<%
  // ===== Guard de sesión =====
  Integer uid = (Integer) session.getAttribute("userId");
  if (uid == null) {
    response.sendRedirect(request.getContextPath()+"/Vista/Login.jsp");
    return;
  }

  int tid = 0;
  try { tid = Integer.parseInt(request.getParameter("tid")); } catch(Exception ignore){}
  if (tid <= 0) {
    response.sendRedirect(request.getContextPath()+"/Vista/MisTickets.jsp");
    return;
  }

  TicketDAO dao = new TicketDAO();
  java.util.Optional<utils.Ticket> opt = dao.findForUser(tid, uid);
  if (!opt.isPresent()) {
    response.sendRedirect(request.getContextPath()+"/Vista/MisTickets.jsp");
    return;
  }

  utils.Ticket t = opt.get();

  DateTimeFormatter df = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
  String dateStr = (t.getEventDateTime()!=null)
        ? t.getEventDateTime().format(df)
        : (t.getDate()!=null ? t.getDate() : "");

  String venue   = t.getVenue()!=null ? t.getVenue() : "";
  String title   = t.getEventTitle()!=null ? t.getEventTitle() : "Evento";
  String status  = t.getStatus()!=null ? t.getStatus() : "VALIDO";

  String statusLabel = status;
  String statusClass  = "pill-ok";

  if ("USADO".equalsIgnoreCase(status)) {
      statusClass = "pill-used";
      statusLabel = "USADO";
  } else if ("REEMBOLSADO".equalsIgnoreCase(status)) {
      statusClass = "pill-refund";
      statusLabel = "REEMBOLSADO";
  } else if (!"VÁLIDO".equalsIgnoreCase(status) && !"VALIDO".equalsIgnoreCase(status)) {
      statusClass = "pill-used";
  } else {
      statusLabel = "VÁLIDO";
  }

  String ctx = request.getContextPath();
  String username = (String) session.getAttribute("userName");
  if (username == null || username.trim().isEmpty()) {
      username = "CLIENTE LIVEPASS";
  }
%>
<!DOCTYPE html>
<html lang="es">
<head>
  <%@ include file="../Includes/head_base.jspf" %>
  <title>Ticket #<%= tid %> — Livepass Buga</title>

  <style>
    body{
      background:#050816;
    }

    .page-shell{
      max-width: 1080px;
      margin: 0 auto;
      padding: 2.5rem 1.25rem 3.5rem;
    }
    @media(min-width:1024px){
      .page-shell{ padding-inline:0; }
    }

    .ticket-frame{
      position:relative;
      border-radius:24px;
      overflow:hidden;
      background:
        radial-gradient(circle at 0 0,rgba(255,255,255,.07),transparent 55%),
        radial-gradient(circle at 100% 130%,rgba(56,189,248,.22),transparent 60%),
        #050816;
      border:1px solid rgba(148,163,184,.55);
      box-shadow:0 28px 80px rgba(15,23,42,.95);
      color:#e5e7eb;
    }

    .ticket-inner{
      display:grid;
      grid-template-columns:minmax(0,3.1fr) minmax(0,1fr);
      min-height:230px;
    }
    @media(max-width:830px){
      .ticket-inner{
        grid-template-columns:1fr;
      }
    }

    .ticket-left{
      position:relative;
      padding:1.7rem 1.9rem 1.4rem;
      overflow:hidden;
      isolation:isolate;
    }

    .ticket-bg{
      position:absolute;
      inset:0;
      z-index:-2;
      background:
        linear-gradient(120deg,rgba(15,23,42,.9),rgba(15,23,42,.6)),
        url("https://images.unsplash.com/photo-1470229722913-7c0e2dbbafd3?auto=format&fit=crop&w=1200&q=80") center/cover no-repeat;
      opacity:.95;
    }
    .ticket-gradient{
      position:absolute;
      inset:0;
      z-index:-1;
      background:
        radial-gradient(circle at 0 0,rgba(56,189,248,.48),transparent 55%),
        radial-gradient(circle at 80% 100%,rgba(168,85,247,.55),transparent 60%);
      mix-blend-mode:screen;
      opacity:.75;
    }

    .ticket-right{
      position:relative;
      background:linear-gradient(180deg,#020617,#020617 40%,#020617);
      display:flex;
      flex-direction:column;
      justify-content:space-between;
      padding:1.1rem .95rem;
      border-left:1px dashed rgba(148,163,184,.55);
    }

    .side-brand{
      writing-mode:vertical-rl;
      text-orientation:mixed;
      font-weight:900;
      letter-spacing:.25em;
      font-size:.75rem;
      text-transform:uppercase;
      color:rgba(148,163,184,.85);
    }

    .side-logo{
      position:absolute;
      top:.5rem;
      right:.7rem;
      font-size:.7rem;
      text-align:right;
      color:#e5e7eb;
    }
    .side-logo span{
      display:block;
      font-weight:900;
      letter-spacing:.12em;
      text-transform:uppercase;
    }
    .side-logo .brand{
      font-size:.78rem;
    }
    .side-logo .city{
      font-size:.68rem;
      color:rgba(148,163,184,.9);
    }

    .pill{
      display:inline-flex;
      align-items:center;
      gap:.35rem;
      padding:.22rem .7rem;
      border-radius:999px;
      font-weight:800;
      font-size:.7rem;
      letter-spacing:.08em;
      text-transform:uppercase;
    }
    .pill-ok{
      background:rgba(16,185,129,.20);
      color:#bbf7d0;
      border:1px solid rgba(16,185,129,.40);
    }
    .pill-used{
      background:rgba(148,163,184,.20);
      color:#e5e7eb;
      border:1px solid rgba(148,163,184,.48);
    }
    .pill-refund{
      background:rgba(244,63,94,.20);
      color:#fecdd3;
      border:1px solid rgba(244,63,94,.40);
    }
    .pill-code{
      background:rgba(15,23,42,.90);
      color:#e5e7eb;
      border:1px dashed rgba(148,163,184,.9);
      font-family:ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas,"Liberation Mono","Courier New",monospace;
    }
    .pill-qty{
      background:rgba(59,130,246,.20);
      color:#bfdbfe;
      border:1px solid rgba(59,130,246,.45);
    }

    .title-main{
      font-size:1.4rem;
      line-height:1.1;
      font-weight:900;
      letter-spacing:-.03em;
      text-transform:uppercase;
    }
    .subtitle{
      font-size:.8rem;
      letter-spacing:.18em;
      text-transform:uppercase;
      color:#e5e7eb;
      opacity:.9;
      font-weight:700;
    }

    .label{
      font-size:.7rem;
      letter-spacing:.18em;
      text-transform:uppercase;
      color:rgba(226,232,240,.85);
    }
    .value{
      font-size:1rem;
      font-weight:800;
      letter-spacing:.08em;
      text-transform:uppercase;
    }

    .meta-line{
      font-size:.8rem;
      color:rgba(226,232,240,.92);
      display:flex;
      align-items:center;
      gap:.4rem;
    }

    .barcode{
      margin-top:1.4rem;
      padding-top:.75rem;
      border-top:1px dashed rgba(148,163,184,.7);
      display:flex;
      align-items:flex-end;
      justify-content:space-between;
      gap:1rem;
    }
    .barcode-stripes{
      flex:1;
      height:32px;
      background-image:repeating-linear-gradient(
        to right,
        rgba(15,23,42,.05) 0,
        rgba(15,23,42,.05) 2px,
        rgba(248,250,252,.95) 2px,
        rgba(248,250,252,.95) 4px
      );
      border-radius:6px;
      overflow:hidden;
    }
    .barcode-code{
      font-family:ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas,"Liberation Mono","Courier New",monospace;
      font-size:.72rem;
      color:rgba(226,232,240,.9);
    }

    .qr-card{
      position:relative;
      border-radius:18px;
      padding:.75rem;
      background:radial-gradient(circle at 0 0,#020617,#020617 60%);
      border:1px solid rgba(148,163,184,.8);
      display:flex;
      flex-direction:column;
      align-items:center;
      gap:.45rem;
      box-shadow:0 18px 40px rgba(15,23,42,1);
    }
    .qr-card img{
      border-radius:12px;
      border:1px solid rgba(248,250,252,.65);
      display:block;
    }
    .qr-help{
      font-size:.65rem;
      color:rgba(148,163,184,.9);
      text-align:center;
    }

    .actions-row{
      margin-top:1.2rem;
      display:flex;
      flex-wrap:wrap;
      gap:.6rem;
      justify-content:flex-start;
    }
    .btn-ghost{
      padding:.6rem 1rem;
      border-radius:999px;
      border:1px solid rgba(148,163,184,.6);
      background:rgba(15,23,42,.9);
      font-size:.8rem;
      font-weight:700;
      display:inline-flex;
      align-items:center;
      gap:.35rem;
      transition: border-color .16s, background .16s, transform .1s;
    }
    .btn-ghost:hover{
      border-color:#e5e7eb;
      background:rgba(15,23,42,1);
      transform:translateY(-1px);
    }

    .extras-grid{
      margin-top:1.6rem;
      display:grid;
      grid-template-columns:repeat(3, minmax(0,1fr));
      gap:1rem;
    }
    @media(max-width:900px){
      .extras-grid{ grid-template-columns:1fr 1fr; }
    }
    @media(max-width:640px){
      .extras-grid{ grid-template-columns:1fr; }
    }

    .extra-card{
      border-radius:18px;
      background:rgba(15,23,42,.92);
      border:1px solid rgba(15,23,42,1);
      overflow:hidden;
      box-shadow:0 18px 40px rgba(15,23,42,.75);
    }
    .extra-head{
      padding:.55rem .9rem;
      font-size:.75rem;
      text-transform:uppercase;
      letter-spacing:.16em;
      color:rgba(148,163,184,.95);
      border-bottom:1px solid rgba(15,23,42,1);
      background:linear-gradient(90deg,rgba(15,23,42,1),rgba(76,29,149,.6));
    }
    .extra-body{
      padding:.5rem;
    }
    .extra-body iframe,
    .extra-body img{
      border-radius:12px;
      width:100%;
      display:block;
    }
    .extra-body p{
      font-size:.8rem;
      color:rgba(209,213,219,.95);
    }

    .page-top{
      display:flex;
      align-items:center;
      justify-content:space-between;
      gap:.75rem;
      margin-bottom:1.3rem;
    }
    .page-top-sub{
      font-size:.8rem;
      color:rgba(148,163,184,.96);
    }

    .badge-mini{
      border-radius:999px;
      padding:.15rem .65rem;
      border:1px solid rgba(148,163,184,.6);
      font-size:.7rem;
      text-transform:uppercase;
      letter-spacing:.14em;
      color:rgba(226,232,240,.9);
    }

    @keyframes fadeUp{
      from{opacity:0; transform:translateY(8px);}
      to{opacity:1; transform:translateY(0);}
    }
    .animate-fadeUp{ animation:fadeUp .45s ease forwards; }

  </style>
</head>
<body class="text-white font-sans">
  <%@ include file="../Includes/nav_base.jspf" %>

  <main class="page-shell">
    <!-- Encabezado -->
    <div class="page-top">
      <div>
        <span class="badge-mini">Ticket digital</span>
        <h1 class="text-xl font-extrabold tracking-tight leading-snug mt-1">
          Detalle de tu entrada
        </h1>
        <p class="page-top-sub">
          Escanea el código al ingresar al evento. No es necesario imprimir el ticket.
        </p>
      </div>
      <div class="text-right text-xs text-white/60">
        ID Ticket<br>
        <span class="pill pill-code">#<%= tid %></span>
      </div>
    </div>

    <!-- Ticket principal -->
    <article class="ticket-frame animate-fadeUp">
      <div class="ticket-inner">

        <!-- IZQUIERDA -->
        <section class="ticket-left">
          <div class="ticket-bg"></div>
          <div class="ticket-gradient"></div>

          <div class="subtitle">LIVEPASSBUGA · TICKET</div>
          <h2 class="title-main mt-1"><%= title %></h2>

          <div class="mt-3 flex flex-wrap items-center gap-2">
            <span class="pill <%= statusClass %>"><%= statusLabel %></span>
            <% if (t.getQty() > 1) { %>
              <span class="pill pill-qty"><%= t.getQty() %> ENTRADAS</span>
            <% } %>
          </div>

          <div class="mt-4 grid gap-3 sm:grid-cols-2">
            <div>
              <div class="label">Nombre</div>
              <div class="value"><%= username.toUpperCase() %></div>
            </div>
            <div>
              <div class="label">Código</div>
              <div class="value">LPB-<%= String.format("%06d", tid) %></div>
            </div>
          </div>

          <div class="mt-3 space-y-1">
            <% if (dateStr != null && !dateStr.isEmpty()) { %>
              <div class="meta-line">📅 <%= dateStr %></div>
            <% } %>
            <% if (venue != null && !venue.isEmpty()) { %>
              <div class="meta-line">📍 <%= venue %></div>
            <% } %>
          </div>

          <div class="barcode">
            <div class="barcode-stripes"></div>
            <div class="barcode-code">
              REF <%= String.format("%08d", tid) %>
            </div>
          </div>
        </section>

        <!-- DERECHA -->
        <aside class="ticket-right">
          <div class="side-logo">
            <span class="brand">LIVEPASS BUGA</span>
            <span class="city">TICKETS & EVENTOS</span>
          </div>

          <div class="qr-card">
            <img
              src="<%= ctx %>/Control/qr_image.jsp?tid=<%= tid %>&s=260"
              alt="Código QR del ticket <%= tid %>"
              loading="eager"
              width="260"
              height="260">
            <div class="qr-help">
              Acerca la pantalla al lector en la entrada. <br/>
              No compartas este código públicamente.
            </div>
          </div>

          <div class="flex items-center justify-between mt-3 text-[0.7rem] text-slate-400">
            <span>GENERADO POR LIVEPASSBUGA</span>
            <span>QR • ACCESO ÚNICO</span>
          </div>
        </aside>

      </div>
    </article>

    <!-- Botones principales -->
    <div class="actions-row">
      <a class="btn-primary ripple"
         href="<%= ctx %>/Control/ct_ticket_pdf.jsp?tid=<%= tid %>">
        ⬇ Descargar PDF
      </a>
      <a class="btn-ghost ripple"
         href="<%= ctx %>/Control/qr_image.jsp?tid=<%= tid %>&s=1024&dl=1"
         target="_blank">
        🔳 Descargar código QR
      </a>
      <a class="btn-ghost ripple" href="#"
         onclick="navigator.clipboard && navigator.clipboard.writeText(window.location.href); return false;">
        🔗 Compartir enlace
      </a>
      <a class="btn-ghost ripple"
         href="<%= ctx %>/Vista/HomeCliente.jsp">
        ← Volver al menú principal
      </a>
    </div>

    <!-- Extras: música, mapa, tips -->
    <section class="extras-grid">
      <!-- Spotify -->
      <article class="extra-card">
        <div class="extra-head">Playlist previa</div>
        <div class="extra-body">
          <iframe style="border-radius:12px"
                  src="https://open.spotify.com/embed/playlist/37i9dQZF1DX8j8N3F0pi8f?utm_source=generator&theme=0"
                  width="100%" height="180" frameborder="0"
                  allowfullscreen=""
                  allow="autoplay; clipboard-write; encrypted-media; fullscreen; picture-in-picture">
          </iframe>
        </div>
      </article>

      <!-- Mapa -->
      <article class="extra-card">
        <div class="extra-head">Cómo llegar</div>
        <div class="extra-body">
          <iframe
            width="100%" height="180" style="border:0; border-radius:12px"
            loading="lazy" allowfullscreen
            referrerpolicy="no-referrer-when-downgrade"
            src="https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d15943.60708651485!2d-76.3067!3d3.9009!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x8e3873a88baf93cd%3A0x8b9b7d5e3e4b7a5c!2sBuga%2C%20Valle%20del%20Cauca!5e0!3m2!1ses!2sco!4v1700000000000">
          </iframe>
        </div>
      </article>

      <!-- Tips / info -->
      <article class="extra-card">
        <div class="extra-head">Tips para el show</div>
        <div class="extra-body">
          <img src="https://images.unsplash.com/photo-1512428559087-560fa5ceab42?auto=format&fit=crop&w=600&q=80"
               alt="Ambiente de concierto">
          <p class="mt-2">
            Llega con anticipación para evitar filas, ten tu documento a la mano y asegúrate de
            que el brillo de tu pantalla esté al máximo para facilitar la lectura del código.
          </p>
        </div>
      </article>
    </section>
  </main>

  <script>
    // Ripple
    (function(){
      document.querySelectorAll('.ripple').forEach(function(b){
        b.addEventListener('click',function(e){
          const r=this.getBoundingClientRect();
          const s=document.createElement('span');
          const z=Math.max(r.width,r.height);
          s.style.width=s.style.height=z+'px';
          s.style.left=(e.clientX-r.left-z/2)+'px';
          s.style.top =(e.clientY-r.top -z/2)+'px';
          this.appendChild(s);
          setTimeout(function(){s.remove();},600);
        });
      });
    })();
  </script>
</body>
</html>

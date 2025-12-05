<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="dao.EventDAO, utils.Event" %>
<%@ page import="java.time.format.DateTimeFormatter" %>

<%
  // --- Parámetro ---
  int eventId = 0;
  try { eventId = Integer.parseInt(request.getParameter("id")); } catch(Exception ignore){}
  if (eventId <= 0) { response.sendRedirect(request.getContextPath()+"/Vista/PaginaPrincipal.jsp"); return; }

  // --- Cargar evento ---
  EventDAO dao = new EventDAO();
  Event ev = dao.findById(eventId).orElse(null);
  if (ev == null) { response.sendRedirect(request.getContextPath()+"/Vista/PaginaPrincipal.jsp"); return; }

  // --- Presentación ---
  DateTimeFormatter df = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
  String dateStr = (ev.getDateTime()!=null) ? ev.getDateTime().format(df) : ev.getDate();

  String st = (ev.getStatus()!=null ? ev.getStatus().name() : "BORRADOR");
  String pill =
     "PUBLICADO".equalsIgnoreCase(st)  ? "bg-emerald-500/20 text-emerald-200" :
     "FINALIZADO".equalsIgnoreCase(st) ? "bg-white/15 text-white/80"         :
                                         "bg-yellow-500/20 text-yellow-200";

  int cap  = Math.max(0, ev.getCapacity());
  int sold = Math.max(0, ev.getSold());
  int disp = Math.max(0, cap - sold);
  int prog = (cap>0) ? (int)Math.round((sold*100.0)/cap) : 0; if (prog>100) prog=100;

  boolean publicado = "PUBLICADO".equalsIgnoreCase(st);
  boolean agotado   = (cap > 0 && disp == 0);

  String ctx = request.getContextPath();
  boolean logged = (session.getAttribute("userId") != null);
  String baseBuy = logged
      ? (ctx + "/Vista/Checkout.jsp?eventId=" + ev.getId() + "&qty=")   // qty se añade por JS/links
      : (ctx + "/Vista/Login.jsp");
%>

<!DOCTYPE html>
<html lang="es">
<head>
  <%@ include file="../Includes/head_base.jspf" %>
  <title><%= ev.getTitle()!=null? ev.getTitle() : "Evento" %> — Detalle</title>
  <style>
    /* Tarjeta con gradiente sutil y borde */
    .card-grad{
      background: linear-gradient(180deg, rgba(255,255,255,.06), rgba(255,255,255,.04));
      border-radius: 18px;
      box-shadow: 0 10px 40px rgba(0,0,0,.45), inset 0 1px 0 rgba(255,255,255,.04);
    }
    .hover-lift{ transition: transform .18s, box-shadow .25s }
    .hover-lift:hover{ transform: translateY(-2px); box-shadow: 0 18px 55px rgba(0,0,0,.55) }

    /* Chips */
    .chip{
      display:inline-flex;align-items:center;gap:.45rem;
      border:1px solid rgba(255,255,255,.12);
      background:rgba(255,255,255,.06);
      border-radius:9999px;padding:.42rem .72rem;font-weight:700
    }

    /* Barra disponibilidad */
    .bar-bg{height:10px;border-radius:9999px;background:rgba(255,255,255,.12)}
    .bar-fg{height:10px;border-radius:9999px;background:#6c5ce7;box-shadow:0 0 0 1px rgba(255,255,255,.1) inset}

    /* Hero sin recortes + glow separado */
    .hero{ position:relative; overflow:visible; }
    .hero-glow{
      position:absolute; left:-25%; right:-25%; bottom:-80px; height:240px;
      background:radial-gradient(closest-side, rgba(108,92,231,.28), transparent 70%);
      filter: blur(40px); pointer-events:none; z-index:-1;
    }

    /* Sidebar sticky */
    .card-sticky{ position:sticky; top:84px }

    /* Cantidad */
    .qty{display:flex;align-items:center;gap:.45rem}
    .qty button{width:38px;height:38px;border-radius:12px;border:1px solid rgba(255,255,255,.15);background:rgba(255,255,255,.05)}
    .qty input{width:76px;text-align:center;border:1px solid rgba(255,255,255,.15);background:rgba(255,255,255,.05);
               border-radius:12px;padding:.58rem .6rem}

    /* CTA móvil pegajoso */
    @media (max-width: 640px){
      .mobile-cta{position:sticky;bottom:0;z-index:20;background:linear-gradient(180deg,rgba(11,14,22,0),#0b0e16 30%,#0b0e16)}
    }
  </style>
</head>
<body class="text-white font-sans">
  <%@ include file="../Includes/nav_base.jspf" %>

  <!-- HERO -->
  <section class="hero max-w-6xl mx-auto px-5 pt-8">
    <div class="hero-glow"></div>
    <div class="card-grad ring p-6 md:p-7 hover-lift">
      <div class="flex items-start justify-between gap-3">
        <h1 class="text-2xl md:text-4xl font-extrabold leading-tight">
          <%= ev.getTitle()!=null? ev.getTitle() : "(sin título)" %>
        </h1>
        <span class="px-2.5 py-1 rounded-full text-xs font-bold <%= pill %>"><%= st %></span>
      </div>

      <div class="mt-3 flex flex-wrap gap-2 text-white/85">
        <span class="chip">📅 <%= dateStr %></span>
        <span class="chip">📍 <%= ev.getVenue()!=null? ev.getVenue() : "" %><% if (ev.getCity()!=null && !ev.getCity().trim().isEmpty()) { %> • <%= ev.getCity() %><% } %></span>
        <% if (ev.getGenre()!=null && !ev.getGenre().trim().isEmpty()) { %><span class="chip">🎵 <%= ev.getGenre() %></span><% } %>
        <% if (cap>0) { %><span class="chip">🧍 Capacidad: <%= cap %></span><span class="chip">🎟️ Vendidos: <%= sold %></span><% } %>
      </div>

      <% if (cap>0) { %>
      <div class="mt-5">
        <div class="flex justify-between text-sm text-white/70 mb-2">
          <span>Disponibilidad</span>
          <span><%= disp %> disponibles</span>
        </div>
        <div class="bar-bg"><div class="bar-fg" style="width:<%= prog %>%"></div></div>
      </div>
      <% } %>
    </div>
  </section>

  <!-- CONTENIDO + SIDEBAR -->
  <main class="max-w-6xl mx-auto px-5 py-8 grid lg:grid-cols-3 gap-7">
    <!-- Columna principal -->
    <section class="lg:col-span-2 space-y-5">
      <article class="card-grad ring p-6 rounded-2xl">
        <h2 class="font-bold text-lg mb-2">Sobre el evento</h2>
        <p class="text-white/70 leading-relaxed">
          Disfruta de una experiencia única. Validación rápida con QR y entradas digitales.
          Si manejas una descripción larga desde la base de datos, imprímela aquí.
        </p>

        <div class="grid sm:grid-cols-3 gap-4 mt-6">
          <div class="card-grad ring rounded-xl p-4">
            <div class="text-white/70 text-sm">Precio</div>
            <div class="text-xl font-extrabold"><%= ev.getPriceFormatted() %></div>
          </div>
          <div class="card-grad ring rounded-xl p-4">
            <div class="text-white/70 text-sm">Lugar</div>
            <div class="font-semibold"><%= ev.getVenue()!=null? ev.getVenue():"" %></div>
          </div>
          <div class="card-grad ring rounded-xl p-4">
            <div class="text-white/70 text-sm">Fecha</div>
            <div class="font-semibold"><%= dateStr %></div>
          </div>
        </div>
      </article>

      <article class="card-grad ring p-6 rounded-2xl">
        <h3 class="font-bold text-lg mb-2">Información importante</h3>
        <ul class="list-disc pl-5 text-white/70 space-y-1">
          <li>Presenta el código QR el día del evento.</li>
          <li>Las compras no son reembolsables salvo cancelación.</li>
          <li>Llega con anticipación para un ingreso más ágil.</li>
        </ul>
      </article>

      <!-- Mobile CTA -->
      <div class="sm:hidden mobile-cta pt-4">
        <div class="card-grad ring rounded-2xl p-4 flex items-center justify-between gap-3">
          <div>
            <div class="text-xs text-white/70">Desde</div>
            <div class="text-xl font-extrabold"><%= ev.getPriceFormatted() %></div>
          </div>
          <% if (publicado && !agotado) { %>
            <a id="buyMobile" class="btn-primary ripple" href="<%= logged ? (baseBuy + 1) : baseBuy %>">Comprar</a>
          <% } else { %>
            <button class="px-4 py-2 rounded-xl bg-white/10 text-white/60 cursor-not-allowed" disabled>No disponible</button>
          <% } %>
        </div>
      </div>
    </section>

    <!-- Sidebar compra -->
    <aside class="card-sticky space-y-5">
      <div class="card-grad ring rounded-2xl p-6">
        <h3 class="font-bold text-lg">Comprar entradas</h3>

        <div class="mt-3 border-t border-white/10 pt-4">
          <div class="text-white/70 text-sm">Precio unitario</div>
          <div class="text-2xl font-extrabold"><%= ev.getPriceFormatted() %></div>
        </div>

        <div class="mt-4">
          <label class="text-white/80 text-sm">Cantidad</label>
          <div class="qty mt-2">
            <button type="button" id="lessBtn">−</button>
            <input id="qtyInput" type="number" min="1" max="<%= Math.max(1, disp>0?disp:1) %>" value="1"/>
            <button type="button" id="moreBtn">+</button>
          </div>
          <% if (cap>0) { %>
            <div class="text-white/60 text-xs mt-1">Máx. <%= Math.max(1, disp) %> disponibles</div>
          <% } %>
        </div>

        <div class="mt-5">
          <% if (publicado && !agotado) { %>
            <a id="buyBtn" class="btn-primary ripple w-full inline-flex justify-center" href="<%= logged ? (baseBuy + 1) : baseBuy %>">
              Comprar ahora
            </a>
          <% } else if (!publicado) { %>
            <button class="w-full px-4 py-3 rounded-xl bg-white/10 text-white/60 cursor-not-allowed" disabled>No publicado</button>
          <% } else { %>
            <button class="w-full px-4 py-3 rounded-xl bg-white/10 text-white/60 cursor-not-allowed" disabled>Agotado</button>
          <% } %>
        </div>

        <div class="mt-4 flex items-center justify-between">
          <button id="shareBtn" class="px-4 py-2 rounded-xl border border-white/15 hover:border-white/30 font-bold transition">
            Compartir
          </button>
          <a class="px-4 py-2 rounded-xl border border-white/15 hover:border-white/30 font-bold transition"
             href="<%= ctx %>/Vista/ExplorarEventos.jsp">Volver a explorar</a>
        </div>
      </div>
    </aside>
  </main>

  <script>
    // Ripple
    (function(){ document.querySelectorAll('.ripple').forEach(function(b){
      b.addEventListener('click',function(e){
        var r=this.getBoundingClientRect(),s=document.createElement('span'),z=Math.max(r.width,r.height);
        s.style.width=s.style.height=z+'px'; s.style.left=(e.clientX-r.left-z/2)+'px'; s.style.top=(e.clientY-r.top-z/2)+'px';
        this.appendChild(s); setTimeout(function(){s.remove();},600);
      });
    });})();

    // Cantidad + actualizar links de compra
    (function(){
      var qty  = document.getElementById('qtyInput');
      var less = document.getElementById('lessBtn');
      var more = document.getElementById('moreBtn');
      var buy  = document.getElementById('buyBtn');
      var buyM = document.getElementById('buyMobile');
      if(!qty) return;

      function clamp(){
        var min = parseInt(qty.min||'1',10), max = parseInt(qty.max||'99',10);
        var v = parseInt(qty.value||'1',10);
        if(isNaN(v)) v = 1;
        v = Math.max(min, Math.min(max, v));
        qty.value = v;
        updateLinks(v);
      }
      function updateLinks(v){
        var base = "<%= logged ? baseBuy : baseBuy %>";
        if(buy)  buy.href  = base + v;
        if(buyM) buyM.href = base + v;
      }
      less && less.addEventListener('click', function(){ qty.value = (parseInt(qty.value||'1',10) || 1) - 1; clamp(); });
      more && more.addEventListener('click', function(){ qty.value = (parseInt(qty.value||'1',10) || 1) + 1; clamp(); });
      qty.addEventListener('input', clamp);
      clamp();
    })();

    // Compartir (clipboard + Web Share si está)
    (function(){
      var share = document.getElementById('shareBtn');
      if(!share) return;
      share.addEventListener('click', async function(){
        var url = window.location.href;
        if (navigator.share) {
          try { await navigator.share({title: document.title, url}); return; } catch(e){}
        }
        try {
          await navigator.clipboard.writeText(url);
          share.textContent = "¡Link copiado!";
          setTimeout(function(){ share.textContent="Compartir"; }, 1400);
        } catch(e){
          alert("Copia el enlace: " + url);
        }
      });
    })();
  </script>
</body>
</html>

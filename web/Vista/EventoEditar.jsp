<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="dao.EventDAO, utils.Event" %>
<%@ page import="java.time.*, java.time.format.DateTimeFormatter" %>
<%@ page import="java.math.BigDecimal" %>

<%
  // ==== Guard de sesión y rol ====
  Integer uid  = (Integer) session.getAttribute("userId");
  String  role = (String)  session.getAttribute("role");
  if (uid == null) { response.sendRedirect(request.getContextPath()+"/Vista/Login.jsp"); return; }
  if (role == null || !"ORGANIZADOR".equalsIgnoreCase(role)) {
    response.sendRedirect(request.getContextPath()+"/Vista/PaginaPrincipal.jsp");
    return;
  }

  // ==== Parámetro id ====
  int id = 0;
  try { id = Integer.parseInt(request.getParameter("id")); } catch(Exception ignore){}

  Event ev = null;
  if (id > 0) { ev = new EventDAO().findById(id).orElse(null); }
  if (id > 0 && ev == null) {
    response.sendRedirect(request.getContextPath()+"/Vista/EventosOrganizador.jsp?err=notfound");
    return;
  }

  // ==== Helpers de formato ====
  String title   = ev!=null && ev.getTitle()!=null ? ev.getTitle() : "";
  String desc    = ""; // si luego agregas columna descripción, úsala aquí
  String city    = ev!=null && ev.getCity()!=null ? ev.getCity() : "";
  String venue   = ev!=null && ev.getVenue()!=null ? ev.getVenue() : "";
  String genre   = ev!=null && ev.getGenre()!=null ? ev.getGenre() : "";
  int capacity   = ev!=null ? Math.max(0, ev.getCapacity()) : 0;
  int sold       = ev!=null ? Math.max(0, ev.getSold()) : 0;
  BigDecimal price = (ev!=null && ev.getPriceValue()!=null) ? ev.getPriceValue() : BigDecimal.ZERO;
  String status  = ev!=null && ev.getStatus()!=null ? String.valueOf(ev.getStatus()) : "BORRADOR"; // BORRADOR | PUBLICADO | FINALIZADO
  String descripcion = ev!=null && ev.getDescription()!=null ? ev.getDescription() : "";
  String image = ev!=null && ev.getImage()!=null ? ev.getImage() : "";
  
  // datetime-local → yyyy-MM-dd'T'HH:mm
  String dtLocal = "";
  if (ev!=null && ev.getDateTime()!=null) {
    dtLocal = ev.getDateTime().format(DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm"));
  } else if (ev!=null && ev.getDate()!=null && !ev.getDate().isEmpty()) {
    try {
      LocalDateTime ldt = LocalDateTime.parse(ev.getDate()+" 00:00", DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm"));
      dtLocal = ldt.format(DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm"));
    } catch(Exception ignore){}
  }

  // flags toast
  String ok  = request.getParameter("ok");
  String err = request.getParameter("err");
%>

<!DOCTYPE html>
<html lang="es">
<head>
  <%@ include file="../Includes/head_base.jspf" %>
  <title><%= (ev==null? "Crear evento" : "Editar evento — "+title) %></title>

  <style>
    /* ===== Layout / estética ===== */
    .wrap { max-width: 1100px; margin: 0 auto; padding: 2.25rem 1.25rem; }
    .page-title { font-weight: 900; letter-spacing: -.02em; }
    .subtitle { color: rgba(255,255,255,.7); }

    .card {
      border: 1px solid rgba(255,255,255,.12);
      background:
        radial-gradient(1200px 200px at 10% -10%, rgba(108,92,231,.06), transparent),
        rgba(255,255,255,.04);
      border-radius: 18px;
      box-shadow: 0 10px 40px rgba(0,0,0,.45), inset 0 1px 0 rgba(255,255,255,.04);
    }
    .card:hover { box-shadow: 0 14px 54px rgba(0,0,0,.55); }

    /* sticky aside */
    @media (min-width: 1024px){ .sticky-aside{ position: sticky; top: 92px; } }

    /* ===== Form ===== */
    .field label{display:block;margin:0 0 6px;color:rgba(255,255,255,.86);font-size:.93rem;font-weight:700}
    .inpx,.selx,.texx{
      width:100%;padding:0.95rem 1rem;border-radius:12px;background:rgba(255,255,255,.03);
      border:1px solid rgba(255,255,255,.15);color:#fff;outline:none;
      transition:border-color .16s, box-shadow .16s, background .16s;
      font-variant-numeric: tabular-nums;
    }
    .inpx:focus,.selx:focus,.texx:focus{border-color:rgba(0,209,178,.6);box-shadow:0 0 0 3px rgba(0,209,178,.18) inset}
    .hint{color:rgba(255,255,255,.6);font-size:.82rem}
    .row{display:grid; gap: 14px;}
    @media (min-width: 768px){ .row-2{grid-template-columns:repeat(2,1fr)} .row-3{grid-template-columns:repeat(3,1fr)} }

    .btn{display:inline-flex;align-items:center;justify-content:center;font-weight:800;border-radius:12px;transition:transform .12s,border-color .18s,background .18s}
    .btn:active{ transform: translateY(1px) }
    /* NO redefinimos .btn-primary para respetar tu color original global */
    .btn-ghost{ padding:.8rem 1rem; border:1px solid rgba(255,255,255,.16); background:rgba(255,255,255,.04); color:#fff }
    .btn-ghost:hover{ border-color:rgba(255,255,255,.3) }

    .chip{display:inline-flex;align-items:center;gap:.45rem;padding:.35rem .7rem;border-radius:999px;
      border:1px solid rgba(255,255,255,.14);background:rgba(255,255,255,.06);font-weight:800;font-size:.8rem}

    .danger{ color:#ff9aa2 }
    .sep{ height:1px; background:linear-gradient(90deg,transparent,rgba(255,255,255,.18),transparent); margin: 10px 0 0 }

    /* ===== Toasts ===== */
    .toast{
      position:fixed; right:18px; bottom:18px; z-index:60; min-width:260px;
      padding:12px 14px; border-radius:14px; border:1px solid rgba(255,255,255,.14);
      background:rgba(11,14,22,.92); box-shadow: 0 10px 40px rgba(0,0,0,.45);
      display:flex; gap:10px; align-items:flex-start; opacity:0; transform: translateY(8px);
      transition: opacity .18s ease, transform .18s ease;
    }
    .toast.show{ opacity:1; transform: translateY(0) }
    .toast .icon{ font-size:20px; line-height:1 }
    .toast .title{ font-weight:900; }
    .toast.success{ border-color: rgba(0,209,178,.5) }
    .toast.error{ border-color: rgba(255,146,146,.5) }
    .toast .close{ margin-left:auto; opacity:.8; border:1px solid rgba(255,255,255,.15); border-radius:10px; padding:4px 8px; }
    .toast .close:hover{ opacity:1 }

    /* Ripple minimal (opcional si ya lo tienes global) */
    .ripple{ position: relative; overflow: hidden; }
    .ripple span{ position:absolute; border-radius:50%; background:rgba(255,255,255,.35); transform:scale(0); animation:rip .6s ease-out }
    @keyframes rip{ to { transform:scale(3); opacity:0; } }

    /* Botón “guardando” */
    .is-loading{ pointer-events:none; opacity:.75; position:relative }
    .is-loading::after{
      content:""; width:16px; height:16px; border-radius:999px; border:2px solid rgba(255,255,255,.6);
      border-top-color:transparent; animation:spin .7s linear infinite; margin-left:8px; display:inline-block;
    }
    @keyframes spin{ to { transform: rotate(360deg) } }
  </style>
</head>
<body class="text-white font-sans">
  <%@ include file="../Includes/nav_base.jspf" %>

  <main class="wrap">
    <!-- Encabezado -->
    <div class="flex flex-col md:flex-row md:items-center md:justify-between gap-3 mb-6">
      <div>
        <h1 class="page-title text-3xl md:text-4xl"><%= (ev==null? "Crear evento" : "Editar evento") %></h1>
        <p class="subtitle mt-1"><%= (ev==null? "Completa la información y publica tu evento." : "Actualiza la información y guarda los cambios.") %></p>
      </div>
      <div class="flex gap-2">
        <a class="btn btn-ghost ripple" href="<%= request.getContextPath() %>/Vista/EventosOrganizador.jsp">Volver</a>
        <% if (ev!=null) { %>
          <a class="btn btn-ghost ripple" href="<%= request.getContextPath() %>/Vista/EventoDetalle.jsp?id=<%= ev.getId() %>" target="_blank">Ver público</a>
        <% } %>
      </div>
    </div>

    <form action="<%= request.getContextPath() %>/Control/ct_evento_guardar.jsp" method="post" class="grid lg:grid-cols-3 gap-6" id="evForm" novalidate>
      <input type="hidden" name="id" value="<%= (ev!=null? ev.getId() : 0) %>">

      <!-- Columna principal -->
      <section class="card p-5 lg:col-span-2 space-y-5">
        <div class="field">
          <label for="f-title">Título</label>
          <input id="f-title" class="inpx" name="title" required maxlength="120" value="<%= title %>" placeholder="Nombre del evento">
        </div>

        <div class="field">
          <label for="f-desc">Descripción (opcional)</label>
          <textarea id="f-desc" class="texx" name="description" rows="6" placeholder="Cuéntanos del evento..."><%= descripcion %></textarea>
        </div>

        <div class="row row-2">
          <div class="field">
            <label for="f-dt">Fecha y hora</label>
            <input id="f-dt" class="inpx" type="datetime-local" name="datetime" value="<%= dtLocal %>">
            <div class="hint">Formato local del organizador.</div>
          </div>
          <div class="field">
            <label for="f-genre">Género / Tipo</label>
            <select id="f-genre" class="selx" name="genre">
              <option value="">— Seleccionar —</option>
              <%
                String[] gens = {"Reggaetón","Salsa","Rock","Pop","Vallenato","Electrónica","Conferencia","Teatro","Otro"};
                for (String g : gens) {
                  boolean sel = g.equalsIgnoreCase(genre);
              %>
                <option value="<%= g %>" <%= (sel? "selected" : "") %>><%= g %></option>
              <% } %>
            </select>
          </div>
        </div>

        <div class="row row-2">
          <div class="field">
            <label for="f-city">Ciudad</label>
            <input id="f-city" class="inpx" name="city" maxlength="80" value="<%= city %>" placeholder="Ej: Bogotá">
          </div>
          <div class="field">
            <label for="f-venue">Lugar / Venue</label>
            <input id="f-venue" class="inpx" name="venue" maxlength="120" value="<%= venue %>" placeholder="Ej: Movistar Arena">
          </div>
        </div>

        <div class="row row-3">
          <div class="field">
            <label for="f-cap">Capacidad</label>
            <input id="f-cap" class="inpx" type="number" min="0" step="1" name="capacity" value="<%= capacity %>">
          </div>
          <div class="field">
            <label for="f-sold">Vendidos</label>
            <input id="f-sold" class="inpx" type="number" min="0" step="1" name="sold" value="<%= sold %>">
            <div class="hint">Se descuenta de la disponibilidad.</div>
          </div>
          <div class="field">
            <label for="f-price">Precio (COP)</label>
            <input id="f-price" class="inpx" type="number" min="0" step="100" name="price" value="<%= price %>">
          </div>
        </div>

        <div class="row row-2">
          <div class="field">
            <label for="f-status">Estado</label>
            <select id="f-status" class="selx" name="status" required>
              <option value="BORRADOR"   <%= "BORRADOR".equalsIgnoreCase(status)?"selected":"" %>>Borrador</option>
              <option value="PENDIENTE"  <%= "PENDIENTE".equalsIgnoreCase(status)?"selected":"" %>>A revisión</option>
              <option value="FINALIZADO" <%= "FINALIZADO".equalsIgnoreCase(status)?"selected":"" %>>Finalizado</option>
            </select>
          </div>
        </div>
        <div class="row row-1">
        </div>
        <div class="row row-1">
            <div class="field">
              <label for="f-img">URL de la imagen</label>
              <input 
                id="f-img"
                class="inpx"
                name="image"
                maxlength="500"
                value="<%= image %>"
                placeholder="https://example.com/img.jpg"
              >
            </div>
        </div>
        <div class="sep"></div>

        <div class="flex flex-wrap gap-8 items-center pt-1">
          <!-- Mantiene tu color original al no sobreescribir .btn-primary -->
          <button id="btnSave" class="btn btn-primary ripple" type="submit">Guardar cambios</button>
          <a class="btn btn-ghost ripple" href="<%= request.getContextPath() %>/Vista/EventosOrganizador.jsp">Cancelar</a>
          <% if (ev!=null) { %>
            <a class="btn btn-ghost ripple danger"
               href="<%= request.getContextPath() %>/Control/ct_evento_eliminar.jsp?id=<%= ev.getId() %>"
               onclick="return confirm('¿Eliminar este evento? Esta acción es permanente.');">Eliminar</a>
          <% } %>
        </div>
      </section>

      <!-- Columna resumen -->
      <aside class="card p-5 sticky-aside">
        <div class="flex items-center justify-between mb-2">
          <div class="font-extrabold">Resumen</div>
          <span class="chip"><%= (ev==null? "Nuevo" : "#"+ev.getId()) %></span>
        </div>
        <div class="text-white/75 text-sm space-y-2">
          <div><b>Título:</b> <%= title.isEmpty()? "(sin título)" : title %></div>
          <div><b>Fecha:</b> <%= (dtLocal.isEmpty()? "—" : dtLocal.replace('T',' ')) %></div>
          <div><b>Ubicación:</b> <%= venue %> — <%= city %></div>
          <div><b>Género:</b> <%= genre.isEmpty()? "—" : genre %></div>
          <div><b>Capacidad:</b> <%= capacity %> · <b>Vendidos:</b> <%= sold %></div>
          <div><b>Disponibles:</b> <%= Math.max(0, capacity - sold) %></div>
          <div><b>Precio:</b> <%= price %> COP</div>
          <div><b>Estado:</b> <%= status %></div>
          <div><b>Descripción:</b> <%= descripcion.isEmpty() ? "—" : descripcion %></div>
          <div><b>Imagen:</b> <%= image.isEmpty() ? "—" : image %></div>
          <div> <b>Imagen:</b>
            <% if (image != null && !image.isEmpty()) { %>
                <br>
                <img src="<%= image %>" alt="Imagen del evento"
                     style="max-width:200px; border-radius:10px; margin-top:5px;">
            <% } else { %>
                —
            <% } %>
</div>
        </div>
        <div class="sep"></div>
        <p class="hint mt-3">Consejo: mantén “Publicado” solo cuando el contenido esté completo y correcto.</p>
      </aside>
    </form>
  </main>

  <!-- TOASTS -->
  <div id="toastOk" class="toast success" role="status" aria-live="polite" aria-atomic="true">
    <div class="icon">✅</div>
    <div>
      <div class="title">Cambios guardados</div>
      <div class="subtitle">El evento se guardó correctamente.</div>
    </div>
    <button class="close" type="button" aria-label="Cerrar" onclick="this.parentElement.classList.remove('show')">Cerrar</button>
  </div>

  <div id="toastErr" class="toast error" role="alert" aria-live="assertive" aria-atomic="true">
    <div class="icon">⚠️</div>
    <div>
      <div class="title">No se pudo guardar</div>
      <div id="toastErrMsg" class="subtitle">Intenta nuevamente.</div>
    </div>
    <button class="close" type="button" aria-label="Cerrar" onclick="this.parentElement.classList.remove('show')">Cerrar</button>
  </div>

  <script>
    // Validación mínima + evitar doble envío + estado "cargando"
    (function(){
      const f = document.getElementById('evForm');
      const btn = document.getElementById('btnSave');
      if (!f || !btn) return;

      function valid(){
        let ok = true;
        if (!f.title.value.trim()) ok = false;
        if (!f.capacity.value || parseInt(f.capacity.value,10) < 0) ok = false;
        if (!f.price.value    || parseInt(f.price.value,10)    < 0) ok = false;
        return ok;
      }

      f.addEventListener('submit', function(e){
        if (!valid()){
          e.preventDefault();
          showErr("Revisa título, capacidad y precio.");
          return;
        }
        // loading visual
        btn.classList.add('is-loading');
        btn.setAttribute('aria-busy','true');
      });
    })();

    // Ripple
    (function(){ document.querySelectorAll('.ripple').forEach(b=>b.addEventListener('click',function(e){
      const r=this.getBoundingClientRect(),s=document.createElement('span'),z=Math.max(r.width,r.height);
      s.style.width=s.style.height=z+'px'; s.style.left=(e.clientX-r.left-z/2)+'px'; s.style.top=(e.clientY-r.top-z/2)+'px';
      this.appendChild(s); setTimeout(()=>s.remove(),600);
    }));})();

    // Toast helpers
    function showOk(){
      const t = document.getElementById('toastOk');
      if (!t) return;
      t.classList.add('show');
      setTimeout(()=> t.classList.remove('show'), 3500);
    }
    function showErr(msg){
      const t = document.getElementById('toastErr');
      if (!t) return;
      const m = document.getElementById('toastErrMsg');
      if (m && msg) m.textContent = msg;
      t.classList.add('show');
    }

    // Mostrar toasts según query params (?ok=1 &err=...)
    (function(){
      const ok = "<%= ok!=null ? ok : "" %>";
      const er = "<%= err!=null ? err : "" %>";
      if (ok === "1") { showOk(); }
      if (er && er.length) { showErr(decodeURIComponent(er)); }
    })();
  </script>
</body>
</html>

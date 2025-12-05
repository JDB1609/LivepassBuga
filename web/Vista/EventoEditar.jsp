<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="utils.Event, dao.EventDAO" %>
<%@ page import="utils.Locality, dao.LocalityDAO" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="java.util.Locale" %>

<%
    request.setCharacterEncoding("UTF-8");

    // ===== VALIDAR SESIÓN Y ROL =====
    Integer uid  = (Integer) session.getAttribute("userId");
    String  role = (String)  session.getAttribute("role");

    if (uid == null || role == null || !"ORGANIZADOR".equalsIgnoreCase(role)) {
        response.sendRedirect(request.getContextPath() + "/Vista/Login.jsp");
        return;
    }

    // ===== LEER ID DEL EVENTO =====
    int id = 0;
    try {
        id = Integer.parseInt(request.getParameter("id"));
    } catch (Exception ignore) {}

    Event ev = null;

    if (id > 0) {
        EventDAO dao = new EventDAO();
        // solo trae el evento si pertenece a este organizador
        ev = dao.findByIdAndOrganizer(id, uid).orElse(null);
    }

    // Si no existe o no es del organizador, redirigir
    if (id <= 0 || ev == null) {
        response.sendRedirect(
            request.getContextPath() + "/Vista/EventosOrganizador.jsp?err=notfound"
        );
        return;
    }

    // ===== FORMATEAR FECHA/HORA PARA <input type="datetime-local"> =====
    String dtValue = "";
    String dtPretty = "Sin fecha definida";
    if (ev.getDateTime() != null) {
        DateTimeFormatter fmt      = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm");
        DateTimeFormatter fmtPretty = DateTimeFormatter.ofPattern("d 'de' MMM yyyy · HH:mm", new Locale("es","ES"));
        dtValue  = ev.getDateTime().format(fmt);
        dtPretty = ev.getDateTime().format(fmtPretty);
    }

    // status enum → String
    String st = (ev.getStatus() != null) ? ev.getStatus().name() : "BORRADOR";

    // ===== CARGAR LOCALIDADES =====
    LocalityDAO locDao = new LocalityDAO();
    java.util.List<Locality> localidades = new java.util.ArrayList<>();
    try {
        localidades = locDao.findByEvent(ev.getId());
    } catch (Exception ex) {
        ex.printStackTrace();
    }

    int capTotal = ev.getCapacity(); // viene del SUM(tt.capacity)
    String imgUrl = (ev.getImage() != null && !ev.getImage().isEmpty())
                    ? ev.getImage()
                    : "https://images.pexels.com/photos/1190297/pexels-photo-1190297.jpeg?auto=compress&cs=tinysrgb&w=1600";
%>
<!DOCTYPE html>
<html lang="es">
<head>
    <%@ include file="../Includes/head_base.jspf" %>
    <title>Editar evento</title>

    <style>
      :root{
        --hero-img: url("https://images.pexels.com/photos/1190297/pexels-photo-1190297.jpeg?auto=compress&cs=tinysrgb&w=1600");
        --accent:#22e3c4;
        --accent-soft:rgba(34,227,196,.18);
        --accent2:#6c5ce7;
        --bg:#020617;
        --card-bg:rgba(15,23,42,.98);
        --border-subtle:rgba(148,163,184,.55);
      }

      *{
        box-sizing:border-box;
      }

      body{
        min-height:100vh;
        background:
          radial-gradient(circle at top,var(--accent-soft),transparent 55%),
          #020617;
        color:#e5e7eb;
        font-family: Inter, system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
        -webkit-font-smoothing:antialiased;
      }

      .lp-hero{
        position:relative;
        min-height:calc(100vh - 64px);
        display:flex;
        align-items:flex-start;
        justify-content:center;
        padding:3.5rem 1.25rem 3rem;
      }

      .lp-hero::before{
        content:"";
        position:absolute;
        inset:0;
        background-image:var(--hero-img);
        background-size:cover;
        background-position:center;
        opacity:0.13;
        filter:grayscale(40%);
      }

      .lp-hero::after{
        content:"";
        position:absolute;
        inset:0;
        background:
          radial-gradient(circle at 10% 0%,rgba(56,189,248,.55),transparent 55%),
          radial-gradient(circle at 90% 0%,rgba(236,72,153,.5),transparent 55%),
          linear-gradient(to bottom,#020617 0%,#020617 45%,#020617 100%);
        mix-blend-mode:screen;
        opacity:.9;
        pointer-events:none;
      }

      .lp-hero-inner{
        position:relative;
        z-index:1;
        width:100%;
        max-width:80rem;
      }

      .lp-card{
        position:relative;
        background:var(--card-bg);
        border-radius:26px;
        border:1px solid rgba(148,163,184,.35);
        box-shadow:
          0 24px 80px rgba(15,23,42,.95),
          0 0 0 1px rgba(15,23,42,.9);
        backdrop-filter:blur(20px);
        padding:2.3rem 2.5rem 2.4rem;
        overflow:hidden;
      }

      .lp-card::before{
        content:"";
        position:absolute;
        inset:0;
        border-radius:inherit;
        padding:1px;
        background:
          linear-gradient(120deg,rgba(34,197,235,.55),rgba(94,234,212,.1),rgba(129,140,248,.6));
        -webkit-mask:
          linear-gradient(#000,#000) content-box,
          linear-gradient(#000,#000);
        -webkit-mask-composite:xor;
        mask-composite:exclude;
        opacity:.5;
        pointer-events:none;
      }

      @media (max-width:1023px){
        .lp-card{padding:1.8rem 1.5rem 2rem;border-radius:20px;}
      }

      .lp-chip{
        display:inline-flex;
        align-items:center;
        gap:.45rem;
        padding:.32rem .75rem;
        border-radius:999px;
        border:1px solid rgba(148,163,184,.65);
        background:rgba(15,23,42,.9);
        font-size:.7rem;
        text-transform:uppercase;
        letter-spacing:.08em;
        color:#cbd5f5;
      }
      .lp-chip-dot{
        width:8px; height:8px;
        border-radius:999px;
        background:var(--accent);
        box-shadow:0 0 14px rgba(34,227,196,.95);
      }

      .page-kicker{
        font-size:.75rem;
        color:#9ca3af;
        letter-spacing:.12em;
        text-transform:uppercase;
        margin-bottom:.35rem;
      }

      .page-title{
        font-size:1.6rem;
        font-weight:700;
        letter-spacing:0.02em;
        display:flex;
        align-items:center;
        gap:.55rem;
      }

      .page-subtitle{
        font-size:.88rem;
        color:#cbd5f5;
        margin-top:.3rem;
      }

      .status-pill{
        display:inline-flex;
        align-items:center;
        gap:.4rem;
        border-radius:999px;
        padding:.25rem .7rem;
        font-size:.72rem;
        border:1px solid rgba(148,163,184,.6);
        background:rgba(15,23,42,.9);
        color:#e5e7eb;
      }
      .status-dot{
        width:7px;height:7px;
        border-radius:999px;
      }
      .status-BORRADOR .status-dot{
        background:#facc15;
        box-shadow:0 0 10px rgba(250,204,21,.85);
      }
      .status-PENDIENTE .status-dot{
        background:#38bdf8;
        box-shadow:0 0 10px rgba(56,189,248,.85);
      }
      .status-PUBLICADO .status-dot{
        background:#22c55e;
        box-shadow:0 0 10px rgba(34,197,94,.85);
      }

      .lp-layout{
        display:grid;
        grid-template-columns:minmax(0,2.4fr) minmax(0,1.5fr);
        gap:2rem;
        margin-top:1.6rem;
      }
      @media (max-width:1023px){
        .lp-layout{
          grid-template-columns:minmax(0,1fr);
          gap:1.4rem;
        }
      }

      .lp-layout-main{
        display:flex;
        flex-direction:column;
        gap:1.4rem;
      }

      .lp-layout-side{
        border-radius:20px;
        border:1px solid rgba(148,163,184,.4);
        background:radial-gradient(circle at top,#020617,#020617 60%);
        padding:1.2rem 1.1rem 1.3rem;
        position:relative;
        overflow:hidden;
      }

      .lp-layout-side::before{
        content:"";
        position:absolute;
        inset:0;
        background:
          radial-gradient(circle at 0% 0%,rgba(56,189,248,.4),transparent 55%),
          radial-gradient(circle at 100% 0%,rgba(236,72,153,.4),transparent 55%);
        opacity:.4;
        mix-blend-mode:screen;
        pointer-events:none;
      }

      .side-inner{
        position:relative;
        z-index:1;
      }

      .side-title{
        font-size:.9rem;
        font-weight:600;
        color:#e5e7eb;
        display:flex;
        align-items:center;
        justify-content:space-between;
        gap:.6rem;
        margin-bottom:.55rem;
      }
      .side-title span.helper{
        font-size:.7rem;
        font-weight:400;
        color:#9ca3af;
      }

      .preview-img-wrapper{
        margin-top:.6rem;
        border-radius:18px;
        overflow:hidden;
        border:1px solid rgba(15,23,42,.9);
        box-shadow:0 18px 40px rgba(0,0,0,.9);
      }
      .preview-img-wrapper img{
        display:block;
        width:100%;
        height:160px;
        object-fit:cover;
        transition:transform .6s ease, filter .6s ease;
      }
      .preview-img-wrapper img:hover{
        transform:scale(1.03);
        filter:brightness(1.05);
      }

      .side-meta{
        margin-top:.7rem;
        display:flex;
        flex-direction:column;
        gap:.35rem;
        font-size:.78rem;
        color:#cbd5f5;
      }
      .side-meta-row{
        display:flex;
        align-items:flex-start;
        justify-content:space-between;
        gap:.7rem;
      }
      .side-label{
        color:#9ca3af;
        font-size:.75rem;
      }

      .side-badge{
        display:inline-flex;
        align-items:center;
        gap:.35rem;
        padding:.2rem .6rem;
        border-radius:999px;
        background:rgba(15,23,42,.94);
        border:1px solid rgba(148,163,184,.5);
        font-size:.7rem;
        color:#e5e7eb;
      }

      .pill-soft{
        border-radius:999px;
        padding:.2rem .55rem;
        border:1px dashed rgba(148,163,184,.5);
        font-size:.68rem;
        color:#9ca3af;
      }

      .field-label{
        font-size:.8rem;
        font-weight:600;
        color:#e5e7eb;
        margin-bottom:.3rem;
        display:flex;
        align-items:center;
        gap:.4rem;
      }
      .field-label span.helper{
        font-size:.7rem;
        font-weight:400;
        color:#9ca3af;
      }

      .field-input, .field-textarea, .ui-select{
        width:100%;
        border-radius:14px;
        border:1px solid rgba(148,163,184,.65);
        background:rgba(15,23,42,.86);
        padding:.7rem .9rem;
        font-size:.85rem;
        color:#e5e7eb;
        outline:none;
        transition:border-color .15s, box-shadow .15s, background .15s, transform .1s;
      }
      .field-input::placeholder,
      .field-textarea::placeholder{
        color:#6b7280;
      }
      .field-input:focus,
      .field-textarea:focus,
      .ui-select:focus{
        border-color:var(--accent);
        box-shadow:0 0 0 1px rgba(34,227,196,.6);
        background:rgba(15,23,42,1);
        transform:translateY(-1px);
      }
      .field-textarea{
        resize:none;
        min-height:110px;
      }
      .ui-select option{
        background:#020617;
        color:#f9fafb;
      }

      .btn-primary{
        background:linear-gradient(120deg,var(--accent2),var(--accent));
        padding:.7rem 1.6rem;
        border-radius:999px;
        font-size:.9rem;
        font-weight:700;
        border:none;
        cursor:pointer;
        display:inline-flex;
        align-items:center;
        gap:.45rem;
        box-shadow:0 18px 40px rgba(76,29,149,.9);
        color:#f9fafb;
        position:relative;
        overflow:hidden;
      }
      .btn-primary::after{
        content:"";
        position:absolute;
        inset:0;
        background:radial-gradient(circle at 0 0,rgba(255,255,255,.3),transparent 55%);
        opacity:0;
        transition:opacity .2s;
      }
      .btn-primary:hover::after{
        opacity:1;
      }
      .btn-primary:hover{
        transform:translateY(-1px);
      }

      .btn-secondary{
        padding:.55rem 1.1rem;
        border-radius:999px;
        border:1px solid rgba(148,163,184,.7);
        background:rgba(15,23,42,.9);
        font-size:.82rem;
        color:#e5e7eb;
        display:inline-flex;
        align-items:center;
        gap:.35rem;
        text-decoration:none;
        cursor:pointer;
        transition:background .15s, border-color .15s, transform .1s;
      }
      .btn-secondary:hover{
        background:rgba(15,23,42,1);
        border-color:rgba(148,163,184,.9);
        transform:translateY(-1px);
      }

      .image-drop{
        border-radius:18px;
        border:1px dashed rgba(148,163,184,.7);
        background:radial-gradient(circle at top,#111827,#020617 80%);
        padding:1.1rem 1rem 1.3rem;
        font-size:.8rem;
        color:#9ca3af;
        box-shadow:0 18px 40px rgba(0,0,0,.85);
        position:relative;
        overflow:hidden;
      }
      .image-drop-helper{
        font-size:.72rem;
        color:#9ca3af;
        margin-bottom:.4rem;
      }
      .image-drop-helper strong{
        color:#e5e7eb;
        font-weight:600;
      }
      .image-drop-input-wrapper{
        position:relative;
        margin-top:.3rem;
      }
      .image-drop-input-wrapper .field-input{
        padding-left:2.2rem;
        font-size:.8rem;
      }
      .image-drop-input-icon{
        position:absolute;
        left:.7rem;
        top:50%;
        transform:translateY(-50%);
        font-size:.85rem;
        opacity:.8;
      }
      .image-chip-row{
        display:flex;
        flex-wrap:wrap;
        gap:.35rem;
        margin-top:.7rem;
        font-size:.67rem;
      }
      .image-chip{
        padding:.2rem .6rem;
        border-radius:999px;
        border:1px solid rgba(148,163,184,.6);
        background:rgba(15,23,42,.9);
        color:#cbd5f5;
      }

      /* Tabla de localidades */
      .zones-table{
        width:100%;
        border-collapse:separate;
        border-spacing:0 .4rem;
        font-size:.78rem;
      }
      .zones-table thead th{
        text-align:left;
        padding-bottom:.25rem;
        color:#9ca3af;
        font-weight:600;
      }
      .zones-table tbody td{
        padding:.15rem .3rem .15rem 0;
        vertical-align:top;
      }
      .zone-name-input,
      .zone-cap-input,
      .zone-price-input{
        font-size:.78rem;
        padding:.55rem .75rem;
        border-radius:999px;
      }

      .helper-small{
        font-size:.7rem;
        color:#94a3b8;
      }

      .hidden{
        display:none !important;
      }

      /* MODAL ELIMINAR LOCALIDAD */
      .modal-backdrop{
        position:fixed;
        inset:0;
        background:rgba(15,23,42,.88);
        display:flex;
        align-items:center;
        justify-content:center;
        z-index:60;
      }
      .modal-card{
        width:100%;
        max-width:380px;
        background:#020617;
        border-radius:20px;
        border:1px solid rgba(148,163,184,.7);
        box-shadow:0 30px 80px rgba(0,0,0,.9);
        padding:1.4rem 1.4rem 1.1rem;
      }
      .modal-title{
        font-size:1rem;
        font-weight:600;
        display:flex;
        align-items:center;
        gap:.6rem;
        margin-bottom:.35rem;
      }
      .modal-title span.icon{
        width:26px;
        height:26px;
        border-radius:999px;
        background:rgba(248,113,113,.13);
        display:inline-flex;
        align-items:center;
        justify-content:center;
        color:#f97373;
        border:1px solid rgba(248,113,113,.35);
      }
      .modal-body{
        font-size:.84rem;
        color:#d1d5db;
        margin-bottom:.9rem;
      }
      .modal-actions{
        display:flex;
        justify-content:flex-end;
        gap:.6rem;
        margin-top:.4rem;
      }
      .btn-ghost{
        background:transparent;
        border-radius:999px;
        border:1px solid rgba(148,163,184,.6);
        padding:.45rem 1rem;
        font-size:.8rem;
        color:#e5e7eb;
        cursor:pointer;
      }
      .btn-danger{
        background:linear-gradient(120deg,#f97373,#fb7185);
        border-radius:999px;
        border:none;
        padding:.45rem 1.1rem;
        font-size:.8rem;
        color:#020617;
        font-weight:600;
        cursor:pointer;
        box-shadow:0 14px 30px rgba(248,113,113,.8);
      }
    </style>
</head>
<body class="text-white">
    <%@ include file="../Includes/nav_base.jspf" %>

    <section class="lp-hero">
      <div class="lp-hero-inner">
        <div class="lp-card">
          <div class="flex items-start justify-between gap-4 mb-4">
            <div>
              <div class="page-kicker">
                Panel del organizador
              </div>
              <div class="page-title">
                Editar evento
                <span class="pill-soft">ID #<%= ev.getId() %></span>
              </div>
              <p class="page-subtitle">
                Ajusta la información clave del show: datos básicos, localidades, portada y estado de venta.
              </p>
            </div>
            <div class="flex flex-col items-end gap-2">
              <div class="lp-chip">
                <span class="lp-chip-dot"></span>
                Editor en vivo · Guardar para aplicar cambios
              </div>
              <div class="status-pill status-<%= st %>">
                <span class="status-dot"></span>
                <span style="text-transform:capitalize;">
                  Estado: <%= st.toLowerCase() %>
                </span>
              </div>
            </div>
          </div>

          <div class="lp-layout">
            <!-- COLUMNA PRINCIPAL (FORM) -->
            <div class="lp-layout-main">
              <form action="<%= request.getContextPath() %>/Control/ct_event_update.jsp" method="post">
                <!-- ID oculto -->
                <input type="hidden" name="id" value="<%= ev.getId() %>" />

                <div style="display:flex;flex-direction:column;gap:1.2rem;">

                  <!-- NOMBRE -->
                  <div>
                    <label class="field-label">
                      Nombre del evento
                      <span class="helper">(obligatorio)</span>
                    </label>
                    <input
                      type="text"
                      name="title"
                      value="<%= ev.getTitle() != null ? ev.getTitle() : "" %>"
                      class="field-input"
                      required
                    />
                    <p class="helper-small" style="margin-top:.3rem;">
                      Piensa en el nombre como el “gancho” principal de tu campaña.
                    </p>
                  </div>

                  <!-- CATEGORÍA + GÉNERO -->
                  <div class="grid" style="gap:1.1rem;grid-template-columns:repeat(auto-fit,minmax(0, min(260px,100%)));">
                    <div>
                      <label class="field-label">
                        Categoría
                        <span class="helper">para organizar en la web</span>
                      </label>
                      <select name="category" class="ui-select">
                        <%
                          String cat = ev.getCategories() != null ? ev.getCategories() : "";
                        %>
                        <option value="">Selecciona una categoría</option>
                        <option value="MUSICA"      <%= "MUSICA".equalsIgnoreCase(cat) ? "selected" : "" %>>Concierto / Música</option>
                        <option value="DEPORTES"    <%= "DEPORTES".equalsIgnoreCase(cat) ? "selected" : "" %>>Deportes</option>
                        <option value="TEATRO"      <%= "TEATRO".equalsIgnoreCase(cat) ? "selected" : "" %>>Teatro / Artes escénicas</option>
                        <option value="CONFERENCIA" <%= "CONFERENCIA".equalsIgnoreCase(cat) ? "selected" : "" %>>Conferencias</option>
                        <option value="FESTIVAL"    <%= "FESTIVAL".equalsIgnoreCase(cat) ? "selected" : "" %>>Festivales</option>
                        <option value="OTROS"       <%= "OTROS".equalsIgnoreCase(cat) ? "selected" : "" %>>Otros</option>
                      </select>
                    </div>

                    <div>
                      <label class="field-label">
                        Género / temática
                        <span class="helper">visible en la ficha</span>
                      </label>
                      <input
                        type="text"
                        name="genre"
                        value="<%= ev.getGenre() != null ? ev.getGenre() : "" %>"
                        class="field-input"
                      />
                    </div>
                  </div>

                  <!-- TIPO + LUGAR + CIUDAD -->
                  <div class="grid" style="gap:1.1rem;grid-template-columns:repeat(auto-fit,minmax(0, min(260px,100%)));">
                    <div>
                      <label class="field-label">Tipo de evento</label>
                      <select name="event_type" class="ui-select">
                        <%
                          String et = ev.getEventType() != null ? ev.getEventType() : "";
                        %>
                        <option value="PRESENCIAL" <%= "PRESENCIAL".equalsIgnoreCase(et) ? "selected" : "" %>>Presencial</option>
                        <option value="VIRTUAL"    <%= "VIRTUAL".equalsIgnoreCase(et)    ? "selected" : "" %>>Virtual</option>
                        <option value="HIBRIDO"    <%= "HIBRIDO".equalsIgnoreCase(et)    ? "selected" : "" %>>Híbrido</option>
                      </select>
                    </div>
                    <div>
                      <label class="field-label">Lugar (venue)</label>
                      <input
                        type="text"
                        name="venue"
                        value="<%= ev.getVenue() != null ? ev.getVenue() : "" %>"
                        class="field-input"
                        required
                      />
                    </div>
                    <div>
                      <label class="field-label">Ciudad</label>
                      <input
                        type="text"
                        name="city"
                        value="<%= ev.getCity() != null ? ev.getCity() : "" %>"
                        class="field-input"
                        required
                      />
                    </div>
                  </div>

                  <!-- FECHA Y HORA -->
                  <div>
                    <label class="field-label">
                      Fecha y hora
                      <span class="helper">inicio del evento</span>
                    </label>
                    <input
                      type="datetime-local"
                      name="date_time"
                      value="<%= dtValue %>"
                      class="field-input"
                      required
                    />
                  </div>

                  <!-- AFORO / LOCALIDADES -->
                  <div style="margin-top:1.2rem;display:flex;flex-direction:column;gap:1.1rem;">
                    <div class="grid" style="gap:1.1rem;grid-template-columns:repeat(auto-fit,minmax(0, min(260px,100%)));">
                      <div>
                        <label class="field-label">
                          Capacidad total
                          <span class="helper">se puede recalcular desde las localidades</span>
                        </label>
                        <input
                          type="number"
                          name="capacity"
                          id="capacityTotal"
                          min="0"
                          class="field-input"
                          value="<%= capTotal > 0 ? capTotal : 0 %>"
                        />
                        <p class="helper-small" style="margin-top:.3rem;">
                          Si cambias los aforos por localidad, usa el botón de cálculo automático.
                        </p>
                      </div>
                    </div>

                    <div>
                      <label class="field-label">
                        Localidades y aforos
                        <span class="helper">capacidad y precio por sección</span>
                      </label>

                      <div style="border-radius:18px;border:1px solid rgba(148,163,184,.45);padding:1rem 0.9rem 1.1rem;background:rgba(15,23,42,.9);box-shadow:0 18px 40px rgba(0,0,0,.8);">
                        <table class="zones-table">
                          <thead>
                            <tr>
                              <th>Localidad</th>
                              <th>Capacidad</th>
                              <th>Precio (COP)</th>
                              <th>Acción</th>
                            </tr>
                          </thead>
                          <tbody id="zonesList">
                            <%
                              int idx = 1;
                              if (localidades != null && !localidades.isEmpty()) {
                                  for (Locality loc : localidades) {
                            %>
                            <tr data-zone-row="<%= idx %>">
                              <td>
                                <input
                                  name="zone_name[]"
                                  class="field-input zone-name-input"
                                  placeholder="Localidad <%= idx %>"
                                  value="<%= loc.getName() != null ? loc.getName() : "" %>"
                                />
                              </td>
                              <td>
                                <input
                                  type="number"
                                  min="0"
                                  name="zone_capacity[]"
                                  class="field-input zone-cap-input"
                                  placeholder="Ej. 1000"
                                  value="<%= loc.getCapacity() %>"
                                />
                              </td>
                              <td>
                                <input
                                  name="zone_price[]"
                                  class="field-input zone-price-input"
                                  placeholder="Ej. 120000"
                                  value="<%= loc.getPrice() != null ? loc.getPrice().toPlainString() : "" %>"
                                />
                              </td>
                              <td>
                                <button
                                  type="button"
                                  class="btn-secondary"
                                  style="font-size:.7rem;padding:.2rem .6rem;"
                                  onclick="openDeleteZoneModal(this)"
                                >
                                  ✖
                                </button>
                              </td>
                            </tr>
                            <%
                                  idx++;
                                  }
                              } else {
                            %>
                            <!-- si no hay localidades, 4 filas por defecto -->
                            <tr data-zone-row="1">
                              <td><input name="zone_name[]" class="field-input zone-name-input" placeholder="PLATEA A" value="PLATEA A" /></td>
                              <td><input type="number" min="0" name="zone_capacity[]" class="field-input zone-cap-input" placeholder="Ej. 3000" /></td>
                              <td><input name="zone_price[]" class="field-input zone-price-input" placeholder="Ej. 150000" /></td>
                              <td><button type="button" class="btn-secondary" style="font-size:.7rem;padding:.2rem .6rem;" onclick="openDeleteZoneModal(this)">✖</button></td>
                            </tr>
                            <tr data-zone-row="2">
                              <td><input name="zone_name[]" class="field-input zone-name-input" placeholder="PLATEA B" value="PLATEA B" /></td>
                              <td><input type="number" min="0" name="zone_capacity[]" class="field-input zone-cap-input" placeholder="Ej. 2800" /></td>
                              <td><input name="zone_price[]" class="field-input zone-price-input" placeholder="Ej. 130000" /></td>
                              <td><button type="button" class="btn-secondary" style="font-size:.7rem;padding:.2rem .6rem;" onclick="openDeleteZoneModal(this)">✖</button></td>
                            </tr>
                            <tr data-zone-row="3">
                              <td><input name="zone_name[]" class="field-input zone-name-input" placeholder="GENERAL" value="GENERAL" /></td>
                              <td><input type="number" min="0" name="zone_capacity[]" class="field-input zone-cap-input" placeholder="Ej. 2000" /></td>
                              <td><input name="zone_price[]" class="field-input zone-price-input" placeholder="Ej. 90000" /></td>
                              <td><button type="button" class="btn-secondary" style="font-size:.7rem;padding:.2rem .6rem;" onclick="openDeleteZoneModal(this)">✖</button></td>
                            </tr>
                            <tr data-zone-row="4">
                              <td><input name="zone_name[]" class="field-input zone-name-input" placeholder="VIP" value="VIP" /></td>
                              <td><input type="number" min="0" name="zone_capacity[]" class="field-input zone-cap-input" placeholder="Ej. 1000" /></td>
                              <td><input name="zone_price[]" class="field-input zone-price-input" placeholder="Ej. 180000" /></td>
                              <td><button type="button" class="btn-secondary" style="font-size:.7rem;padding:.2rem .6rem;" onclick="openDeleteZoneModal(this)">✖</button></td>
                            </tr>
                            <%
                              }
                            %>
                          </tbody>
                        </table>

                        <div style="display:flex;flex-wrap:wrap;gap:.4rem;margin-top:.7rem;justify-content:flex-end;">
                          <button type="button" class="btn-secondary" id="btnCalcCap" style="font-size:.72rem;padding:.35rem .8rem;">
                            ⇱ Calcular capacidad total
                          </button>
                          <button type="button" class="btn-secondary" id="btnAddZone" style="font-size:.72rem;padding:.35rem .8rem;">
                            ＋ Añadir localidad
                          </button>
                        </div>

                        <p style="font-size:0.7rem;color:#94a3b8;margin-top:.4rem;">
                          Estos campos viajan como listas:
                          <code>zone_name[]</code>, <code>zone_capacity[]</code> y <code>zone_price[]</code>.
                        </p>
                      </div>
                    </div>
                  </div>

                  <!-- DESCRIPCIÓN -->
                  <div>
                    <label class="field-label">
                      Descripción del evento
                      <span class="helper">máx. 500 caracteres</span>
                    </label>
                    <textarea
                      name="description"
                      maxlength="500"
                      rows="4"
                      class="field-textarea"
                    ><%= ev.getDescription() != null ? ev.getDescription() : "" %></textarea>
                  </div>

                  <!-- PORTADA + ALT -->
                  <div class="grid" style="gap:1.1rem;grid-template-columns:repeat(auto-fit,minmax(0, min(260px,100%)));">
                    <div>
                      <label class="field-label">
                        Portada del evento
                        <span class="helper">URL de imagen</span>
                      </label>
                      <div class="image-drop">
                        <p class="image-drop-helper">
                          <strong>Tip:</strong> usa una foto con público, luces o escenario. Debe transmitir
                          energía y ganas de estar ahí.
                        </p>
                        <div class="image-drop-input-wrapper">
                          <span class="image-drop-input-icon">🔗</span>
                          <input
                            name="image"
                            id="imageInput"
                            class="field-input"
                            placeholder="Pega la URL de la imagen"
                            value="<%= ev.getImage() != null ? ev.getImage() : "" %>"
                          />
                        </div>
                        <div class="image-chip-row">
                          <span class="image-chip">Recomendado: 1600 × 900 px</span>
                          <span class="image-chip">Peso máx. aprox. 1 MB</span>
                          <span class="image-chip">Evita textos pequeños en la imagen</span>
                        </div>
                      </div>
                    </div>

                    <div>
                      <label class="field-label">
                        Texto alternativo (accesibilidad)
                        <span class="helper">opcional</span>
                      </label>
                      <textarea
                        name="image_alt"
                        rows="3"
                        class="field-textarea"
                        placeholder="Ej. Fotografía de un concierto con luces azules y público levantando las manos."
                      ><%= ev.getImageAlt() != null ? ev.getImageAlt() : "" %></textarea>
                    </div>
                  </div>

                  <!-- ESTADO -->
                  <div>
                    <label class="field-label">Estado</label>
                    <select name="status" class="ui-select">
                      <option value="BORRADOR"   <%= "BORRADOR".equalsIgnoreCase(st)   ? "selected" : "" %>>Borrador</option>
                      <option value="PENDIENTE"  <%= "PENDIENTE".equalsIgnoreCase(st)  ? "selected" : "" %>>Pendiente</option>
                      <option value="PUBLICADO"  <%= "PUBLICADO".equalsIgnoreCase(st)  ? "selected" : "" %>>Publicado (visible para venta)</option>
                    </select>
                  </div>

                </div>

                <!-- BOTONES -->
                <div style="display:flex;flex-wrap:wrap;gap:.75rem;margin-top:1.8rem;align-items:center;">
                  <button type="submit" class="btn-primary">
                    Guardar cambios
                  </button>

                  <a
                    href="<%= request.getContextPath() %>/Vista/EventosOrganizador.jsp"
                    class="btn-secondary"
                  >
                    Cancelar
                  </a>

                  <span class="helper-small">
                    Los cambios impactarán la ficha pública una vez el estado esté publicado.
                  </span>
                </div>
              </form>
            </div>

            <!-- COLUMNA LATERAL (RESUMEN / PREVIEW) -->
            <aside class="lp-layout-side">
              <div class="side-inner">
                <div class="side-title">
                  <div>
                    Resumen del evento
                    <div class="helper-small" style="margin-top:.15rem;">
                      Vista rápida para validar que todo “se vea vendible”.
                    </div>
                  </div>
                  <span class="side-badge">
                    🎟️ <%= capTotal > 0 ? capTotal : 0 %> asientos
                  </span>
                </div>

                <div class="preview-img-wrapper" id="previewImgWrapper">
                  <img id="previewImg" src="<%= imgUrl %>" alt="Vista previa portada evento" />
                </div>

                <div class="side-meta">
                  <div class="side-meta-row">
                    <span class="side-label">Nombre</span>
                    <span style="font-weight:500;text-align:right;">
                      <%= ev.getTitle() != null ? ev.getTitle() : "Evento sin nombre" %>
                    </span>
                  </div>
                  <div class="side-meta-row">
                    <span class="side-label">Ciudad / Venue</span>
                    <span style="text-align:right;">
                      <%= ev.getCity() != null ? ev.getCity() : "-" %> ·
                      <%= ev.getVenue() != null ? ev.getVenue() : "-" %>
                    </span>
                  </div>
                  <div class="side-meta-row">
                    <span class="side-label">Fecha</span>
                    <span style="text-align:right;"><%= dtPretty %></span>
                  </div>
                  <div class="side-meta-row">
                    <span class="side-label">Categoría</span>
                    <span style="text-align:right;">
                      <%= (ev.getCategories() != null && !ev.getCategories().isEmpty())
                           ? ev.getCategories()
                           : "Sin categoría" %>
                    </span>
                  </div>
                  <div class="side-meta-row">
                    <span class="side-label">Género</span>
                    <span style="text-align:right;">
                      <%= (ev.getGenre() != null && !ev.getGenre().isEmpty())
                           ? ev.getGenre()
                           : "Sin definir" %>
                    </span>
                  </div>
                </div>

                <div style="margin-top:.9rem;border-top:1px solid rgba(148,163,184,.35);padding-top:.7rem;">
                  <p class="helper-small">
                    Revisa que el aforo, precios y portada estén alineados con la estrategia de venta antes de publicar.
                  </p>
                </div>
              </div>
            </aside>
          </div>
        </div>
      </div>
    </section>

    <!-- MODAL ELIMINAR LOCALIDAD -->
    <div id="deleteZoneModal" class="modal-backdrop hidden">
      <div class="modal-card">
        <div class="modal-title">
          <span class="icon">!</span>
          Eliminar localidad
        </div>
        <div class="modal-body">
          ¿Seguro que quieres eliminar esta localidad? Se perderá su aforo y precio
          y se recalculará la capacidad total.
        </div>
        <div class="modal-actions">
          <button type="button" class="btn-ghost" onclick="closeDeleteZoneModal()">
            Cancelar
          </button>
          <button type="button" class="btn-danger" onclick="confirmDeleteZone()">
            Eliminar
          </button>
        </div>
      </div>
    </div>

    <script>
      // ====== CAPACIDAD TOTAL ======
      function calcCapacityTotal(){
        const capTotal = document.getElementById('capacityTotal');
        if(!capTotal) return;

        let total = 0;
        document.querySelectorAll('.zone-cap-input').forEach(function(inp){
          const v = parseInt(inp.value, 10);
          if(!isNaN(v) && v > 0){ total += v; }
        });
        capTotal.value = total || 0;
      }

      // ====== MODAL ELIMINAR LOCALIDAD ======
      let rowToDelete = null;

      function openDeleteZoneModal(btn){
        rowToDelete = btn.closest('tr');
        const modal = document.getElementById('deleteZoneModal');
        if(modal){
          modal.classList.remove('hidden');
        }
      }

      function closeDeleteZoneModal(){
        rowToDelete = null;
        const modal = document.getElementById('deleteZoneModal');
        if(modal){
          modal.classList.add('hidden');
        }
      }

      function confirmDeleteZone(){
        if(rowToDelete){
          rowToDelete.remove();
          calcCapacityTotal();
        }
        closeDeleteZoneModal();
      }

      (function(){
        const btnCalcCap = document.getElementById('btnCalcCap');
        const btnAddZone = document.getElementById('btnAddZone');
        const zonesList  = document.getElementById('zonesList');
        const imgInput   = document.getElementById('imageInput');
        const previewImg = document.getElementById('previewImg');

        // Calcular capacidad total desde las localidades
        if(btnCalcCap){
          btnCalcCap.addEventListener('click', function(){
            calcCapacityTotal();
          });
        }

        // Añadir nueva localidad
        if(btnAddZone && zonesList){
          btnAddZone.addEventListener('click', function(){
            const tr = document.createElement('tr');

            tr.innerHTML =
              '<td>' +
              '  <input name="zone_name[]" class="field-input zone-name-input" placeholder="Nueva localidad" />' +
              '</td>' +
              '<td>' +
              '  <input type="number" min="0" name="zone_capacity[]" class="field-input zone-cap-input" placeholder="Ej. 1000" />' +
              '</td>' +
              '<td>' +
              '  <input name="zone_price[]" class="field-input zone-price-input" placeholder="Ej. 120000" />' +
              '</td>' +
              '<td>' +
              '  <button type="button" class="btn-secondary" style="font-size:.7rem;padding:.2rem .6rem;" onclick="openDeleteZoneModal(this)">✖</button>' +
              '</td>';

            zonesList.appendChild(tr);
          });
        }

        // Preview en vivo de la imagen
        if(imgInput && previewImg){
          imgInput.addEventListener('input', function(){
            const value = imgInput.value.trim();
            if(value){
              previewImg.src = value;
            }
          });
        }
      })();
    </script>
</body>
</html>
 
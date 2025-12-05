<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="utils.Event, dao.EventDAO" %>
<%@ page import="utils.Locality, dao.LocalityDAO" %>
<%@ page import="java.time.format.DateTimeFormatter" %>

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
    if (ev.getDateTime() != null) {
        DateTimeFormatter fmt = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm");
        dtValue = ev.getDateTime().format(fmt);
    }

    // status enum → String
    String st = (ev.getStatus() != null) ? ev.getStatus().name() : "";

    // ===== CARGAR LOCALIDADES =====
    LocalityDAO locDao = new LocalityDAO();
    java.util.List<Locality> localidades = new java.util.ArrayList<>();
    try {
        localidades = locDao.findByEvent(ev.getId());
    } catch (Exception ex) {
        ex.printStackTrace();
    }

    int capTotal = ev.getCapacity(); // viene del SUM(tt.capacity)
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
        --accent2:#6c5ce7;
      }

      body{
        min-height:100vh;
        background:#020617;
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
        filter:brightness(0.55);
      }
      .lp-hero::after{
        content:"";
        position:absolute;
        inset:0;
        background:radial-gradient(circle at top,rgba(56,189,248,.55),transparent 55%),
                   linear-gradient(to bottom,rgba(15,23,42,.85),rgba(15,23,42,.96));
        mix-blend-mode:screen;
        opacity:.85;
      }

      .lp-hero-inner{
        position:relative;
        z-index:1;
        width:100%;
        max-width:64rem;
      }

      .lp-card{
        background:rgba(15,23,42,.96);
        border-radius:22px;
        border:1px solid rgba(148,163,184,.55);
        box-shadow:0 22px 60px rgba(0,0,0,.9);
        backdrop-filter:blur(18px);
        padding:2.1rem 2.4rem 2.4rem;
      }
      @media (max-width:767px){
        .lp-card{padding:1.7rem 1.4rem 1.9rem;border-radius:18px;}
      }

      .lp-chip{
        display:inline-flex;
        align-items:center;
        gap:.45rem;
        padding:.28rem .7rem;
        border-radius:999px;
        border:1px solid rgba(148,163,184,.65);
        background:rgba(15,23,42,.9);
        font-size:.7rem;
        text-transform:uppercase;
        letter-spacing:.08em;
        color:#cbd5f5;
      }
      .lp-chip-dot{
        width:7px; height:7px;
        border-radius:999px;
        background:var(--accent);
        box-shadow:0 0 12px rgba(34,227,196,.9);
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
        transition:border-color .15s, box-shadow .15s, background .15s;
      }
      .field-input::placeholder,
      .field-textarea::placeholder{
        color:#6b7280;
      }
      .field-input:focus,
      .field-textarea:focus,
      .ui-select:focus{
        border-color:var(--accent);
        box-shadow:0 0 0 1px rgba(34,227,196,.7);
        background:rgba(15,23,42,1);
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
        padding:.7rem 1.5rem;
        border-radius:999px;
        font-size:.9rem;
        font-weight:700;
        border:none;
        cursor:pointer;
        display:inline-flex;
        align-items:center;
        gap:.45rem;
        box-shadow:0 16px 30px rgba(76,29,149,.9);
        color:#f9fafb;
      }
      .btn-secondary{
        padding:.55rem 1.1rem;
        border-radius:999px;
        border:1px solid rgba(148,163,184,.7);
        background:rgba(15,23,42,.85);
        font-size:.85rem;
        color:#e5e7eb;
        display:inline-flex;
        align-items:center;
        gap:.35rem;
        text-decoration:none;
      }

      .image-drop{
        border-radius:18px;
        border:1px solid rgba(148,163,184,.7);
        background:radial-gradient(circle at top,#1f2937,#020617 80%);
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
        background:rgba(15,23,42,.85);
        color:#cbd5f5;
      }

      /* tabla de localidades */
      .zones-table{
        width:100%;
        border-collapse:separate;
        border-spacing:0 .4rem;
        font-size:.78rem;
      }
      .zones-table thead th{
        text-align:left;
        padding-bottom:.15rem;
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
    </style>
</head>
<body class="text-white">
    <%@ include file="../Includes/nav_base.jspf" %>

    <section class="lp-hero">
      <div class="lp-hero-inner">
        <div class="lp-card">
          <div class="flex items-start justify-between gap-3 mb-6">
            <div>
              <div class="lp-chip mb-2">
                <span class="lp-chip-dot"></span>
                Editar evento · ID #<%= ev.getId() %>
              </div>
              <h1 class="text-2xl">Actualiza los datos de tu evento</h1>
              <p class="text-sm text-slate-300 mt-1">
                Ajusta la información básica, fecha, ubicación, aforos, portada y estado.
              </p>
            </div>
          </div>

          <form action="<%= request.getContextPath() %>/Control/ct_event_update.jsp" method="post">
            <!-- ID oculto -->
            <input type="hidden" name="id" value="<%= ev.getId() %>" />

            <!-- INFO BÁSICA -->
            <div style="display:flex;flex-direction:column;gap:1.2rem;">

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
              </div>

              <div class="grid" style="gap:1.1rem;grid-template-columns:repeat(auto-fit,minmax(0, min(260px,100%)));">
                <div>
                  <label class="field-label">
                    Categoría
                    <span class="helper">para ordenar en la web</span>
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
                      <span class="helper">puedes calcularla desde las localidades</span>
                    </label>
                    <input
                      type="number"
                      name="capacity"
                      id="capacityTotal"
                      min="0"
                      class="field-input"
                      value="<%= capTotal > 0 ? capTotal : 0 %>"
                    />
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
                              data-zone="<%= idx %>"
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
                              data-zone="<%= idx %>"
                              class="field-input zone-cap-input"
                              placeholder="Ej. 1000"
                              value="<%= loc.getCapacity() %>"
                            />
                          </td>
                          <td>
                            <input
                              name="zone_price[]"
                              data-zone="<%= idx %>"
                              class="field-input zone-price-input"
                              placeholder="Ej. 120000"
                              value="<%= loc.getPrice() != null ? loc.getPrice().toPlainString() : "" %>"
                            />
                          </td>
                        </tr>
                        <%
                              idx++;
                              }
                          } else {
                        %>
                        <!-- si no hay localidades, 4 filas por defecto -->
                        <tr data-zone-row="1">
                          <td><input name="zone_name[]" data-zone="1" class="field-input zone-name-input" placeholder="PLATEA A" value="PLATEA A" /></td>
                          <td><input type="number" min="0" name="zone_capacity[]" data-zone="1" class="field-input zone-cap-input" placeholder="Ej. 3000" /></td>
                          <td><input name="zone_price[]" data-zone="1" class="field-input zone-price-input" placeholder="Ej. 150000" /></td>
                        </tr>
                        <tr data-zone-row="2">
                          <td><input name="zone_name[]" data-zone="2" class="field-input zone-name-input" placeholder="PLATEA B" value="PLATEA B" /></td>
                          <td><input type="number" min="0" name="zone_capacity[]" data-zone="2" class="field-input zone-cap-input" placeholder="Ej. 2800" /></td>
                          <td><input name="zone_price[]" data-zone="2" class="field-input zone-price-input" placeholder="Ej. 130000" /></td>
                        </tr>
                        <tr data-zone-row="3">
                          <td><input name="zone_name[]" data-zone="3" class="field-input zone-name-input" placeholder="GENERAL" value="GENERAL" /></td>
                          <td><input type="number" min="0" name="zone_capacity[]" data-zone="3" class="field-input zone-cap-input" placeholder="Ej. 2000" /></td>
                          <td><input name="zone_price[]" data-zone="3" class="field-input zone-price-input" placeholder="Ej. 90000" /></td>
                        </tr>
                        <tr data-zone-row="4">
                          <td><input name="zone_name[]" data-zone="4" class="field-input zone-name-input" placeholder="VIP" value="VIP" /></td>
                          <td><input type="number" min="0" name="zone_capacity[]" data-zone="4" class="field-input zone-cap-input" placeholder="Ej. 1000" /></td>
                          <td><input name="zone_price[]" data-zone="4" class="field-input zone-price-input" placeholder="Ej. 180000" /></td>
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

              <!-- PORTADA -->
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
                  <option value="PUBLICADO"  <%= "PUBLICADO".equalsIgnoreCase(st)  ? "selected" : "" %>>Publicado</option>
                  <option value="FINALIZADO" <%= "FINALIZADO".equalsIgnoreCase(st) ? "selected" : "" %>>Finalizado</option>
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
            </div>
          </form>
        </div>
      </div>
    </section>

    <script>
      // Calcular capacidad total desde las localidades
      (function(){
        const btnCalcCap = document.getElementById('btnCalcCap');
        const capTotal   = document.getElementById('capacityTotal');

        if(btnCalcCap && capTotal){
          btnCalcCap.addEventListener('click', function(){
            let total = 0;
            document.querySelectorAll('.zone-cap-input').forEach(function(inp){
              const v = parseInt(inp.value, 10);
              if(!isNaN(v) && v > 0){ total += v; }
            });
            capTotal.value = total || 0;
          });
        }

        // Añadir nueva localidad
        const btnAddZone = document.getElementById('btnAddZone');
        const zonesList  = document.getElementById('zonesList');

        if(btnAddZone && zonesList){
          btnAddZone.addEventListener('click', function(){
            const rows = zonesList.querySelectorAll('tr');
            const nextIndex = rows.length + 1;
            const tr = document.createElement('tr');
            tr.setAttribute('data-zone-row', nextIndex);

            tr.innerHTML =
              '<td>' +
              '  <input name="zone_name[]" data-zone="'+nextIndex+'" class="field-input zone-name-input" placeholder="Localidad '+nextIndex+'" />' +
              '</td>' +
              '<td>' +
              '  <input type="number" min="0" name="zone_capacity[]" data-zone="'+nextIndex+'" class="field-input zone-cap-input" placeholder="Ej. 1000" />' +
              '</td>' +
              '<td>' +
              '  <input name="zone_price[]" data-zone="'+nextIndex+'" class="field-input zone-price-input" placeholder="Ej. 120000" />' +
              '</td>';

            zonesList.appendChild(tr);
          });
        }
      })();
    </script>
</body>
</html>

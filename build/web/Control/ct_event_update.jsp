<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="utils.Event, dao.EventDAO" %>
<%@ page import="utils.Locality, dao.LocalityDAO" %>
<%@ page import="java.time.LocalDateTime" %>
<%@ page import="java.math.BigDecimal" %>

<%
    request.setCharacterEncoding("UTF-8");

    // ===== VALIDAR SESIÓN =====
    Integer uid  = (Integer) session.getAttribute("userId");
    String  role = (String)  session.getAttribute("role");

    if (uid == null || role == null || !"ORGANIZADOR".equalsIgnoreCase(role)) {
        response.sendRedirect(request.getContextPath() + "/Vista/Login.jsp");
        return;
    }

    // ===== ID DEL EVENTO =====
    String idStr = request.getParameter("id");
    int eventId = 0;
    try {
        eventId = Integer.parseInt(idStr != null ? idStr.trim() : "0");
    } catch (Exception ignore) {}

    if (eventId <= 0) {
        response.sendRedirect(
            request.getContextPath() + "/Vista/EventosOrganizador.jsp?ok=0&err=id_invalido"
        );
        return;
    }

    // ===== CAMPOS DEL EVENTO =====
    String title       = request.getParameter("title");
    String venue       = request.getParameter("venue");
    String city        = request.getParameter("city");
    String genre       = request.getParameter("genre");
    String category    = request.getParameter("category");
    String eventType   = request.getParameter("event_type");
    String dtStr       = request.getParameter("date_time");
    String description = request.getParameter("description");
    String image       = request.getParameter("image");
    String imageAlt    = request.getParameter("image_alt");
    String statusParam = request.getParameter("status");

    if (title       == null) title = "";
    if (venue       == null) venue = "";
    if (city        == null) city = "";
    if (genre       == null) genre = "";
    if (category    == null) category = "";
    if (eventType   == null) eventType = "PRESENCIAL";
    if (description == null) description = "";
    if (image       == null) image = "";
    if (imageAlt    == null) imageAlt = "";
    if (statusParam == null) statusParam = "BORRADOR";

    // ===== CAMPOS DE LOCALIDADES (NOMBRES IGUALES AL FORM DE EDITAR) =====
    String[] locNames    = request.getParameterValues("zone_name[]");
    String[] locCapacity = request.getParameterValues("zone_capacity[]");
    String[] locPrice    = request.getParameterValues("zone_price[]");

    try {
        // ===== ARMAR EVENTO =====
        Event e = new Event();
        e.setId(eventId);
        e.setOrganizerId(Long.valueOf(uid));
        e.setTitle(title);
        e.setVenue(venue);
        e.setCity(city);
        e.setGenre(genre);
        e.setCategories(category);
        e.setEventType(eventType);
        e.setDescription(description);
        e.setImage(image);
        e.setImageAlt(imageAlt);
        e.setStatus(statusParam);  // tu Event convierte String -> enum internamente

        if (dtStr != null && !dtStr.isBlank()) {
            e.setDateTime(LocalDateTime.parse(dtStr));
        }

        EventDAO eventDao = new EventDAO();

        // 1) Actualizar datos básicos del evento
        eventDao.update(e, uid);

        // 2) Actualizar LOCALIDADES:
        //    - borrar las anteriores
        //    - insertar las nuevas que vienen del formulario
        LocalityDAO locDao = new LocalityDAO();
        locDao.deleteByEvent(eventId);

        if (locNames != null) {
            for (int i = 0; i < locNames.length; i++) {
                String ln = locNames[i] != null ? locNames[i].trim() : "";

                String cap = "";
                if (locCapacity != null && i < locCapacity.length && locCapacity[i] != null) {
                    cap = locCapacity[i].trim();
                }

                String prc = "";
                if (locPrice != null && i < locPrice.length && locPrice[i] != null) {
                    prc = locPrice[i].trim();
                }

                // fila totalmente vacía → ignorar
                if (ln.isEmpty() && cap.isEmpty() && prc.isEmpty()) {
                    continue;
                }

                int capacidad = 0;
                try {
                    if (!cap.isEmpty()) capacidad = Integer.parseInt(cap);
                } catch (NumberFormatException nfe) {
                    System.out.println("[ct_event_update] Capacidad inválida para " + ln + ": " + cap);
                    capacidad = 0;
                }

                BigDecimal precio = BigDecimal.ZERO;
                try {
                    if (!prc.isEmpty()) {
                        String prcNorm = prc.replace(",", ".");
                        precio = new BigDecimal(prcNorm);
                    }
                } catch (Exception nfe) {
                    System.out.println("[ct_event_update] Precio inválido para " + ln + ": " + prc);
                    precio = BigDecimal.ZERO;
                }

                if (ln.isEmpty()) {
                    continue; // si no tiene nombre, no guardamos la localidad
                }

                Locality loc = new Locality();
                loc.setEventId(eventId);
                loc.setName(ln);
                loc.setCapacity(capacidad);
                loc.setPrice(precio);

                locDao.create(loc);
            }
        }

        // 3) OK → volver al listado
        response.sendRedirect(
            request.getContextPath() + "/Vista/EventosOrganizador.jsp?ok=1"
        );

    } catch (Exception ex) {
        ex.printStackTrace();
        response.setContentType("text/html; charset=UTF-8");
        response.getWriter().println("<h2 style='color:red'>ERROR ACTUALIZANDO EVENTO</h2>");
        response.getWriter().println("<pre>" + ex.getMessage() + "</pre>");
    }
%>

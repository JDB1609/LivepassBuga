<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="utils.Event, dao.EventDAO" %>
<%@ page import="utils.Locality, dao.LocalityDAO" %>
<%@ page import="java.time.LocalDateTime" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="java.util.Arrays" %>

<%
    Integer uid  = (Integer) session.getAttribute("userId");
    String  role = (String)  session.getAttribute("role");

    // Solo ORGANIZADOR puede crear eventos
    if (uid == null) {
        response.sendRedirect(request.getContextPath()+"/Vista/Login.jsp");
        return;
    }
    if (role == null || !"ORGANIZADOR".equalsIgnoreCase(role)) {
        response.sendRedirect(request.getContextPath()+"/Vista/HomeCliente.jsp");
        return;
    }

    request.setCharacterEncoding("UTF-8");

    // ========= CAMPOS DEL EVENTO =========
    String title       = request.getParameter("title");
    String venue       = request.getParameter("venue");
    String city        = request.getParameter("city");
    String genre       = request.getParameter("genre");
    String dtStr       = request.getParameter("date_time");
    String description = request.getParameter("description");
    String image       = request.getParameter("image");
    String category    = request.getParameter("category");
    String eventType   = request.getParameter("event_type");
    String imageAlt    = request.getParameter("image_alt");
    String status      = request.getParameter("status");

    // ========= NORMALIZACIÓN =========
    if (title       == null) title = "";
    if (venue       == null) venue = "";
    if (city        == null) city = "";
    if (genre       == null) genre = "";
    if (description == null) description = " ";
    if (image       == null) image = " ";
    if (category    == null || category.isBlank()) category = "OTROS";
    if (eventType   == null || eventType.isBlank()) eventType = "PRESENCIAL";
    if (imageAlt    == null) imageAlt = "Evento";
    if (status      == null) status = "BORRADOR";

    // ========= CAMPOS DE LOCALIDADES (COINCIDEN CON EL FORM) =========
    // En el form: name="zone_name[]" / "zone_capacity[]" / "zone_price[]"
    String[] locNames    = request.getParameterValues("zone_name[]");
    String[] locCapacity = request.getParameterValues("zone_capacity[]");
    String[] locPrice    = request.getParameterValues("zone_price[]");

    // DEBUG para ver qué llega
    System.out.println("locNames    = " + Arrays.toString(locNames));
    System.out.println("locCapacity = " + Arrays.toString(locCapacity));
    System.out.println("locPrice    = " + Arrays.toString(locPrice));

    try {
        Event e = new Event();

        e.setOrganizerId(Long.valueOf(uid));
        e.setTitle(title);
        e.setVenue(venue);
        e.setCity(city);
        e.setGenre(genre);
        e.setDescription(description);
        e.setImage(image);
        e.setCategories(category);
        e.setEventType(eventType);
        e.setImageAlt(imageAlt);
        e.setStatus(status);

        if (dtStr != null && !dtStr.isBlank()) {
            // <input type="datetime-local"> => "2025-12-04T21:30"
            e.setDateTime(LocalDateTime.parse(dtStr));
        }

        EventDAO eventDao = new EventDAO();

        System.out.println("CREANDO EVENTO:");
        System.out.println("TITLE=" + title);
        System.out.println("CATEGORY=" + category);
        System.out.println("TYPE=" + eventType);

        // 1) Crear evento
        int eventId = eventDao.create(e);
        System.out.println("EVENTO CREADO ID=" + eventId);

        // 2) Crear localidades asociadas al evento
        if (eventId > 0 && locNames != null && locCapacity != null && locPrice != null) {
            LocalityDAO locDao = new LocalityDAO();

            for (int i = 0; i < locNames.length; i++) {
                String ln  = locNames[i] != null ? locNames[i].trim() : "";
                String cap = (i < locCapacity.length && locCapacity[i] != null)
                             ? locCapacity[i].trim() : "";
                String prc = (i < locPrice.length && locPrice[i] != null)
                             ? locPrice[i].trim() : "";

                // Saltar filas completamente vacías
                if (ln.isEmpty() && cap.isEmpty() && prc.isEmpty()) {
                    continue;
                }

                int capacidad = 0;
                try {
                    if (!cap.isEmpty()) {
                        capacidad = Integer.parseInt(cap);
                    }
                } catch (NumberFormatException nfe) {
                    System.out.println("Capacidad inválida para localidad '" + ln + "': " + cap);
                    capacidad = 0;
                }

                BigDecimal precio = BigDecimal.ZERO;
                try {
                    if (!prc.isEmpty()) {
                        String prcNorm = prc.replace(",", ".");
                        precio = new BigDecimal(prcNorm);
                    }
                } catch (Exception nfe) {
                    System.out.println("Precio inválido para localidad '" + ln + "': " + prc);
                    precio = BigDecimal.ZERO;
                }

                // Si no hay nombre, no la creamos
                if (ln.isEmpty()) {
                    System.out.println("Nombre vacío, no se crea localidad.");
                    continue;
                }

                Locality loc = new Locality();
                loc.setEventId(eventId);
                loc.setName(ln);
                loc.setCapacity(capacidad);
                loc.setPrice(precio);

                locDao.create(loc);
                System.out.println("LOCALIDAD CREADA: " + ln +
                                   " cap=" + capacidad +
                                   " price=" + precio);
            }
        } else {
            System.out.println("No se recibieron localidades para este evento.");
        }

        // 3) Redirigir al listado de eventos del organizador
        response.sendRedirect(request.getContextPath() + "/Vista/EventosOrganizador.jsp?ok=1");

    } catch (Exception ex) {
        ex.printStackTrace();
        response.setContentType("text/html; charset=UTF-8");
        response.getWriter().println("<h2 style='color:red'>ERROR CREANDO EVENTO / LOCALIDADES</h2>");
        response.getWriter().println("<pre>" + ex.getMessage() + "</pre>");
    }
%>

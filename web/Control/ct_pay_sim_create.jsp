<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="dao.EventDAO, dao.TicketDAO, utils.Event, java.math.BigDecimal" %>
<%
    Integer uid = (Integer) session.getAttribute("userId");
    if (uid == null) {
        response.sendRedirect(request.getContextPath() + "/Vista/Login.jsp");
        return;
    }

    int eventId = 0;
    int qty     = 1;
    try {
        eventId = Integer.parseInt(request.getParameter("eventId"));
        qty     = Integer.parseInt(request.getParameter("qty"));
    } catch (Exception ignore) {}

    // Limitar cantidad entre 1 y 10
    qty = Math.max(1, Math.min(qty, 10));

    Event ev = new EventDAO().findById(eventId).orElse(null);
    if (ev == null) {
        response.sendRedirect(request.getContextPath() + "/Vista/PaginaPrincipal.jsp");
        return;
    }

    BigDecimal unit = ev.getPrice();
    if (unit == null) unit = BigDecimal.ZERO;
    BigDecimal total = unit.multiply(new BigDecimal(qty));

    // Ejecutar compra directa (sin OrderDAO)
    TicketDAO ticketDao = new TicketDAO();
    TicketDAO.PurchaseResult pr = ticketDao.purchase(eventId, uid, qty, unit);

    if (!pr.ok) {
        // No había cupos o falló algo
        response.sendRedirect(request.getContextPath() + "/Vista/PagoError.jsp");
        return;
    }

    // Guardar info en sesión para mostrar en PagoOK.jsp
    session.setAttribute("lastQrCodes", pr.codes);
    session.setAttribute("lastEventTitle", ev.getTitle());
    session.setAttribute("lastQty", qty);
    session.setAttribute("lastTotal", total);

    response.sendRedirect(request.getContextPath() + "/Vista/PagoOK.jsp");
%>

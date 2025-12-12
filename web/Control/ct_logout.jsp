<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="jakarta.servlet.http.Cookie" %>
<%
    // Evita que páginas protegidas queden en caché al volver con el botón "Atrás"
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate"); // HTTP 1.1
    response.setHeader("Pragma", "no-cache"); // HTTP 1.0
    response.setDateHeader("Expires", 0);     // Proxies

    // Invalidar sesión si existe
    if (session != null) {
        session.invalidate();
    }

    // Borrar cookie JSESSIONID (y otras si las usas tipo "rememberMe" o "auth_token")
    Cookie[] cookies = request.getCookies();
    if (cookies != null) {
        String ctxPath = request.getContextPath();
        String cookiePath = (ctxPath == null || ctxPath.isEmpty()) ? "/" : ctxPath;

        for (Cookie c : cookies) {
            if ("JSESSIONID".equalsIgnoreCase(c.getName())
                    || "rememberMe".equalsIgnoreCase(c.getName())
                    || "auth_token".equalsIgnoreCase(c.getName())) {

                c.setMaxAge(0);
                c.setPath(cookiePath);
                response.addCookie(c);
            }
        }
    }

    // Redirige a la página principal (usa context path para que funcione en cualquier despliegue)
    String home = request.getContextPath() + "/Vista/PaginaPrincipal.jsp";
    response.sendRedirect(home);
%>

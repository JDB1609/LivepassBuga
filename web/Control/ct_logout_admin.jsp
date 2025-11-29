<%@ page contentType="text/html; charset=UTF-8" import="javax.servlet.http.Cookie" %>
<%
  // Evitar que el navegador guarde caché del panel del admin
  response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
  response.setHeader("Pragma", "no-cache");
  response.setDateHeader("Expires", 0);

  // Verifica si la sesión existe
  if (session != null) {
    // Solo limpia si es un administrador autenticado
    if (session.getAttribute("admin") != null) {
      session.removeAttribute("admin");
    }
    session.invalidate();
  }

  // Borra cookies de sesión o autenticación
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

  // Redirige al login de administradores
  String loginAdmin = request.getContextPath() + "/Vista/PaginaPrincipal.jsp";
  response.sendRedirect(loginAdmin);
%>
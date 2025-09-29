<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.sql.*, java.util.*, utils.Conexion" %>

<%
Integer uid = (Integer) session.getAttribute("userId");
if (uid == null) { return; }

Connection cn = null;
try {
  cn = new utils.Conexion().getConnection();

  // KPI: tickets totales (suma de qty)
  long kTotal = 0;
  try (PreparedStatement ps = cn.prepareStatement(
       "SELECT COALESCE(SUM(qty),0) FROM tickets WHERE user_id=?")) {
    ps.setInt(1, uid);
    try (ResultSet rs = ps.executeQuery()) { if (rs.next()) kTotal = rs.getLong(1); }
  }

  // KPI: próximos (eventos futuros con tickets ACTIVO)
  long kUpcoming = 0;
  try (PreparedStatement ps = cn.prepareStatement(
       "SELECT COALESCE(SUM(t.qty),0) " +
       "FROM tickets t JOIN events e ON e.id=t.event_id " +
       "WHERE t.user_id=? AND t.status='ACTIVO' AND " +
       "      ( (e.date_time IS NOT NULL AND e.date_time > NOW()) OR " +
       "        (e.date_time IS NULL AND STR_TO_DATE(e.date, '%d/%m/%Y %H:%i') > NOW()) )")) {
    ps.setInt(1, uid);
    try (ResultSet rs = ps.executeQuery()) { if (rs.next()) kUpcoming = rs.getLong(1); }
  }

  // KPI: reembolsados (suma de qty status=REEMBOLSADO)
  long kRefunded = 0;
  try (PreparedStatement ps = cn.prepareStatement(
       "SELECT COALESCE(SUM(qty),0) FROM tickets WHERE user_id=? AND status='REEMBOLSADO'")) {
    ps.setInt(1, uid);
    try (ResultSet rs = ps.executeQuery()) { if (rs.next()) kRefunded = rs.getLong(1); }
  }

  // Actividad reciente (últimos 5)
  java.util.List<String> recent = new ArrayList<>();
  try (PreparedStatement ps = cn.prepareStatement(
       "SELECT CONCAT(DATE_FORMAT(purchase_at,'%d/%m/%Y %H:%i'),' · REF ',payment_ref,' · ',qty,' tkts') " +
       "FROM tickets WHERE user_id=? ORDER BY purchase_at DESC LIMIT 5")) {
    ps.setInt(1, uid);
    try (ResultSet rs = ps.executeQuery()) {
      while (rs.next()) recent.add(rs.getString(1));
    }
  }

  request.setAttribute("kpi_total",    kTotal);
  request.setAttribute("kpi_upcoming", kUpcoming);
  request.setAttribute("kpi_refunded", kRefunded);
  request.setAttribute("recent_activity", recent);

} catch (Exception e) {
  e.printStackTrace();
} finally {
  try { if (cn!=null) cn.close(); } catch(Exception ignore){}
}
%>

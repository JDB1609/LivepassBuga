package dao;

import utils.Conexion;
import utils.Ticket;

import java.sql.*;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

public class TicketDAO {

    // =========================
    //  MAPEO RESULTSET -> TICKET
    // =========================
    private Ticket map(ResultSet rs) throws SQLException {
        Ticket t = new Ticket();

        // Campos propios de tickets
        t.setId(rs.getInt("id"));
        t.setEventId(rs.getInt("event_id"));
        t.setUserId(rs.getInt("user_id"));

        // ticket_type_id (puede ser NULL)
        try {
            int tt = rs.getInt("ticket_type_id");
            if (rs.wasNull()) {
                t.setTicketTypeId(null);
            } else {
                t.setTicketTypeId(tt);
            }
        } catch (SQLException ignore) {}

        try { t.setQty(rs.getInt("qty")); } catch (SQLException ignore) {}
        try { t.setQtyQrUsed(rs.getInt("qty_qr_used")); } catch (SQLException ignore) {}

        try {
            Timestamp pur = rs.getTimestamp("purchase_at");
            if (pur != null) t.setPurchaseAt(pur.toLocalDateTime());
        } catch (SQLException ignore) {}

        try { t.setPaymentRef(rs.getString("payment_ref")); } catch (SQLException ignore) {}
        // NO USAMOS DOCUMENTO EN EL MODELO
        try { t.setQrData(rs.getString("qr_data")); } catch (SQLException ignore) {}
        try { t.setStatus(rs.getString("status")); } catch (SQLException ignore) {}

        // Campos del evento (JOIN)
        try { t.setEventTitle(rs.getString("title")); } catch (SQLException ignore) {}
        try { t.setVenue(rs.getString("venue")); } catch (SQLException ignore) {}
        try {
            Timestamp dt = rs.getTimestamp("date_time");
            if (dt != null) t.setEventDateTime(dt.toLocalDateTime());
        } catch (SQLException ignore) {}

        return t;
    }

    // =========================================
    //  LISTAS PARA MisTickets.jsp
    // =========================================

    /** Tickets de eventos FUTUROS del usuario (e.date_time >= NOW()) */
    public List<Ticket> listUpcomingByUser(int userId) {
        String sql =
            "SELECT t.*, e.title, e.venue, e.date_time " +
            "FROM tickets t " +
            "JOIN events e ON e.id = t.event_id " +
            "WHERE t.user_id = ? " +
            "  AND e.date_time >= NOW() " +
            "ORDER BY e.date_time ASC, t.id DESC";

        List<Ticket> out = new ArrayList<>();
        Conexion cx = new Conexion();
        try (Connection cn = cx.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql)) {

            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) out.add(map(rs));
            }
        } catch (Exception ex) {
            throw new RuntimeException(ex);
        } finally {
            cx.cerrarConexion();
        }
        return out;
    }

    /** Tickets de eventos PASADOS del usuario (e.date_time < NOW()) */
    public List<Ticket> listPastByUser(int userId) {
        String sql =
            "SELECT t.*, e.title, e.venue, e.date_time " +
            "FROM tickets t " +
            "JOIN events e ON e.id = t.event_id " +
            "WHERE t.user_id = ? " +
            "  AND e.date_time < NOW() " +
            "ORDER BY e.date_time DESC, t.id DESC";

        List<Ticket> out = new ArrayList<>();
        Conexion cx = new Conexion();
        try (Connection cn = cx.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql)) {

            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) out.add(map(rs));
            }
        } catch (Exception ex) {
            throw new RuntimeException(ex);
        } finally {
            cx.cerrarConexion();
        }
        return out;
    }

    /** Todos los tickets del usuario (futuros + pasados) */
    public List<Ticket> listByUser(int userId) {
        String sql =
            "SELECT t.*, e.title, e.venue, e.date_time " +
            "FROM tickets t " +
            "JOIN events e ON e.id = t.event_id " +
            "WHERE t.user_id = ? " +
            "ORDER BY e.date_time DESC, t.id DESC";

        List<Ticket> out = new ArrayList<>();
        Conexion cx = new Conexion();
        try (Connection cn = cx.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql)) {

            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) out.add(map(rs));
            }
        } catch (Exception ex) {
            throw new RuntimeException(ex);
        } finally {
            cx.cerrarConexion();
        }
        return out;
    }

    /** Buscar ticket por id (sin validar propietario) */
    public Optional<Ticket> findById(int ticketId) {
        String sql =
            "SELECT t.*, e.title, e.venue, e.date_time " +
            "FROM tickets t " +
            "JOIN events e ON e.id = t.event_id " +
            "WHERE t.id = ?";

        Conexion cx = new Conexion();
        try (Connection cn = cx.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql)) {

            ps.setInt(1, ticketId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return Optional.of(map(rs));
            }
        } catch (Exception ex) {
            throw new RuntimeException(ex);
        } finally {
            cx.cerrarConexion();
        }
        return Optional.empty();
    }

    // ========================
    //  MÉTODOS PARA PDF / TRANSFER
    // ========================

    /** Buscar ticket por id **y** dueño (seguridad de vistas) */
    public Optional<Ticket> findForUser(int ticketId, int userId) {
        String sql =
            "SELECT t.*, e.title, e.venue, e.date_time " +
            "FROM tickets t JOIN events e ON e.id=t.event_id " +
            "WHERE t.id=? AND t.user_id=?";
        Conexion cx = new Conexion();
        try (Connection cn = cx.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, ticketId);
            ps.setInt(2, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return Optional.of(map(rs));
            }
        } catch (Exception e) { throw new RuntimeException(e); }
        finally { cx.cerrarConexion(); }
        return Optional.empty();
    }

    /** Buscar id de usuario por email (para transferir) */
    public int findUserIdByEmail(String email) {
        String sql = "SELECT id FROM users WHERE email=?";
        Conexion cx = new Conexion();
        try (Connection cn = cx.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (Exception e) { throw new RuntimeException(e); }
        finally { cx.cerrarConexion(); }
        return -1;
    }

    /**
     * Transferir ticket de fromUserId -> toUserId.
     * Solo actualiza el owner; SIN tabla de log (porque tu BD no la tiene).
     */
    public boolean transfer(int ticketId, int fromUserId, int toUserId) {
        Conexion cx = new Conexion();
        Connection cn = null;
        try {
            cn = cx.getConnection();
            cn.setAutoCommit(false);

            String sql =
                "UPDATE tickets t " +
                "JOIN events e ON e.id = t.event_id " +
                "SET t.user_id = ? " +
                "WHERE t.id = ? AND t.user_id = ? AND e.date_time > NOW()";

            try (PreparedStatement ps = cn.prepareStatement(sql)) {
                ps.setInt(1, toUserId);
                ps.setInt(2, ticketId);
                ps.setInt(3, fromUserId);
                int rows = ps.executeUpdate();
                if (rows == 0) { cn.rollback(); return false; }
            }

            cn.commit();
            return true;
        } catch (Exception e) {
            try { if (cn != null) cn.rollback(); } catch (Exception ignore) {}
            throw new RuntimeException(e);
        } finally {
            try { if (cn != null) cn.setAutoCommit(true); cn.close(); } catch (Exception ignore) {}
            cx.cerrarConexion();
        }
    }

       // ========================
    //  COMPRA + CÓDIGOS QR
    // ========================

    /** Resultado de la compra simulada que usa ct_pago_simulado.jsp */
    public static class PurchaseResult {
        public boolean ok;
        public List<String> codes = new ArrayList<>();
    }

    /**
     * Versión antigua (sin ticketTypeId explícito).
     * La dejo por compatibilidad: delega a la nueva con ticketTypeId = 0
     * para que escoja el tipo más barato.
     */
    public PurchaseResult purchase(int eventId, int userId, int qty, BigDecimal unitPrice) {
        return purchase(eventId, userId, qty, unitPrice, 0);
    }

    /**
     * Ejecuta la compra:
     *  - Verifica capacidad usando ticket_types y tickets.qty
     *  - Si ticketTypeId > 0, valida ese aforo concreto
     *  - Si ticketTypeId == 0, toma el tipo más barato del evento
     *  - Inserta UN registro en tickets con qty = cantidad
     *  - Genera un solo QR para todo el grupo (qty_qr_used controla entradas)
     */
    public PurchaseResult purchase(int eventId, int userId, int qty, BigDecimal unitPrice, int ticketTypeId) {
        PurchaseResult pr = new PurchaseResult();
        pr.ok = false;

        Conexion cx = new Conexion();
        Connection cn = null;

        try {
            cn = cx.getConnection();
            cn.setAutoCommit(false);

            int ttId = -1;
            int capacity = 0;
            int sold = 0;

            // 1) Buscar el ticket_type que vamos a usar y sus cupos
            String qCap;
            if (ticketTypeId > 0) {
                // Si viene desde el checkout, validamos ese tipo concreto
                qCap =
                    "SELECT tt.id, tt.capacity, COALESCE(SUM(t.qty),0) AS sold " +
                    "FROM ticket_types tt " +
                    "LEFT JOIN tickets t ON t.ticket_type_id = tt.id " +
                    "WHERE tt.id = ? AND tt.id_event = ? " +
                    "GROUP BY tt.id, tt.capacity " +
                    "FOR UPDATE";
            } else {
                // Fallback: tipo más barato del evento
                qCap =
                    "SELECT tt.id, tt.capacity, COALESCE(SUM(t.qty),0) AS sold " +
                    "FROM ticket_types tt " +
                    "LEFT JOIN tickets t ON t.ticket_type_id = tt.id " +
                    "WHERE tt.id_event = ? " +
                    "GROUP BY tt.id, tt.capacity " +
                    "ORDER BY tt.price ASC " +
                    "LIMIT 1 FOR UPDATE";
            }

            try (PreparedStatement ps = cn.prepareStatement(qCap)) {
                if (ticketTypeId > 0) {
                    ps.setInt(1, ticketTypeId);
                    ps.setInt(2, eventId);
                } else {
                    ps.setInt(1, eventId);
                }

                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        ttId     = rs.getInt("id");
                        capacity = rs.getInt("capacity");
                        sold     = rs.getInt("sold");
                    }
                }
            }

            if (ttId <= 0) {
                // No hay tipos de boleta configurados o el id no corresponde
                cn.rollback();
                return pr;
            }

            if (sold + qty > capacity) {
                // Sin cupos suficientes
                cn.rollback();
                return pr;
            }

            // 2) Insertar ticket (un solo QR para todo el grupo)
            String ref = "SIM-" + (System.currentTimeMillis() % 100000);
            String qr  = "LP|" + ref + "|" + userId + "|" + eventId + "|" + System.currentTimeMillis();

            String insSql =
                "INSERT INTO tickets " +
                "(user_id, event_id, qty, purchase_at, payment_ref, qr_data, qty_qr_used, status, ticket_type_id) " +
                "VALUES (?,?,?,NOW(),?,?,0,'ACTIVO',?)";

            try (PreparedStatement ps = cn.prepareStatement(insSql)) {
                ps.setInt(1, userId);   // user_id
                ps.setInt(2, eventId);  // event_id
                ps.setInt(3, qty);      // qty
                ps.setString(4, ref);   // payment_ref
                ps.setString(5, qr);    // qr_data
                ps.setInt(6, ttId);     // ticket_type_id (el definitivo)
                ps.executeUpdate();
            }

            cn.commit();
            pr.ok = true;
            pr.codes.add(qr);
            return pr;

        } catch (Exception e) {
            try { if (cn != null) cn.rollback(); } catch (Exception ignore) {}
            throw new RuntimeException("Error en purchase", e);
        } finally {
            try { if (cn != null) { cn.setAutoCommit(true); cn.close(); } } catch (Exception ignore) {}
            cx.cerrarConexion();
        }
    }


    // ========================
    //  MÉTODOS PARA SCAN QR
    // ========================

    /** Buscar ticket por qr_data (para el validador de QR) */
    public Optional<Ticket> findByQr(String qrData) {
        String sql =
            "SELECT t.*, e.title, e.venue, e.date_time " +
            "FROM tickets t " +
            "JOIN events e ON e.id = t.event_id " +
            "WHERE t.qr_data = ? " +
            "LIMIT 1";

        Conexion cx = new Conexion();
        try (Connection cn = cx.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql)) {

            ps.setString(1, qrData);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return Optional.of(map(rs));
            }
        } catch (Exception e) {
            throw new RuntimeException(e);
        } finally {
            cx.cerrarConexion();
        }
        return Optional.empty();
    }

    /** Incrementar qty_qr_used en 1 si aún hay cupos disponibles para ese QR */
    public boolean incrementarQtyUsado(int ticketId) {
        String sql =
            "UPDATE tickets " +
            "SET qty_qr_used = qty_qr_used + 1 " +
            "WHERE id = ? AND qty_qr_used < qty";

        Conexion cx = new Conexion();
        try (Connection cn = cx.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql)) {

            ps.setInt(1, ticketId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            throw new RuntimeException(e);
        } finally {
            cx.cerrarConexion();
        }
    }

    // ========= agregados por tipo de boleta y por evento =========

    public int sumUsedByTicketType(int ticketTypeId) {
        String sql = "SELECT COALESCE(SUM(qty_qr_used),0) FROM tickets WHERE ticket_type_id = ?";
        Conexion cx = new Conexion();
        try (Connection cn = cx.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, ticketTypeId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (Exception e) { throw new RuntimeException(e); }
        finally { cx.cerrarConexion(); }
        return 0;
    }

    public int sumTotalByTicketType(int ticketTypeId) {
        String sql = "SELECT COALESCE(SUM(qty),0) FROM tickets WHERE ticket_type_id = ?";
        Conexion cx = new Conexion();
        try (Connection cn = cx.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, ticketTypeId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (Exception e) { throw new RuntimeException(e); }
        finally { cx.cerrarConexion(); }
        return 0;
    }

    public int sumUsedByEvent(int eventId) {
        String sql = "SELECT COALESCE(SUM(qty_qr_used),0) FROM tickets WHERE event_id = ?";
        Conexion cx = new Conexion();
        try (Connection cn = cx.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, eventId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (Exception e) { throw new RuntimeException(e); }
        finally { cx.cerrarConexion(); }
        return 0;
    }

    public int sumTotalByEvent(int eventId) {
        String sql = "SELECT COALESCE(SUM(qty),0) FROM tickets WHERE event_id = ?";
        Conexion cx = new Conexion();
        try (Connection cn = cx.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql)) {
            ps.setInt(1, eventId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        } catch (Exception e) { throw new RuntimeException(e); }
        finally { cx.cerrarConexion(); }
        return 0;
    }
    
    public List<Ticket> listAllTickets() {
        String sql =
            "SELECT t.*, e.title, e.venue, e.date_time " +
            "FROM tickets t " +
            "JOIN events e ON e.id = t.event_id " +
            "ORDER BY e.date_time DESC, t.id DESC";

        List<Ticket> tickets = new ArrayList<>();
        Conexion cx = new Conexion();

        try (Connection cn = cx.getConnection();
             PreparedStatement ps = cn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                tickets.add(map(rs));
            }

        } catch (Exception ex) {
            throw new RuntimeException("Error listAllTickets", ex);
        } finally {
            cx.cerrarConexion();
        }

        return tickets;
    }    
}

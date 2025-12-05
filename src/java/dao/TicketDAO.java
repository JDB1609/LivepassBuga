package dao;

import utils.Conexion;
import utils.Ticket;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

public class TicketDAO {

    // =========================
    // Mapear ResultSet -> Ticket
    // =========================
    private Ticket map(ResultSet rs) throws SQLException {
        Ticket t = new Ticket();

        // Campos de tickets
        t.setId(rs.getInt("id"));
        t.setEventId(rs.getInt("event_id"));
        t.setUserId(rs.getInt("user_id"));

        // purchase_at (opcional)
        try {
            Timestamp pur = rs.getTimestamp("purchase_at");
            if (pur != null) t.setPurchaseAt(pur.toLocalDateTime());
        } catch (SQLException ignore) {}

        // status (si existe en tu BD)
        try {
            String st = rs.getString("status");
            t.setStatus(st);
        } catch (SQLException ignore) {}

        // seat (opcional)
        try { t.setSeat(rs.getString("seat")); } catch (SQLException ignore) {}

        // qr_code (opcional)
        try { t.setQrCode(rs.getString("qr_code")); } catch (SQLException ignore) {}

        // Campos del evento (via JOIN)
        try { t.setEventTitle(rs.getString("title")); } catch (SQLException ignore) {}
        try { t.setVenue(rs.getString("venue")); } catch (SQLException ignore) {}
        try {
            Timestamp dt = rs.getTimestamp("date_time");
            if (dt != null) t.setEventDateTime(dt.toLocalDateTime());
        } catch (SQLException ignore) {}

        return t;
    }

    // =========================================
    // Listas para MisTickets.jsp
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

        List<Ticket> out = new ArrayList<Ticket>();
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

        List<Ticket> out = new ArrayList<Ticket>();
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

        List<Ticket> out = new ArrayList<Ticket>();
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
    // NUEVOS MÉTODOS (QR/PDF/Transfer)
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
     * Transferir ticket de fromUserId -> toUserId
     * Registra un log en ticket_transfers.
     * Nota: no uso filtro por t.status para evitar errores en esquemas sin esa columna.
     */
    public boolean transfer(int ticketId, int fromUserId, int toUserId) {
        Conexion cx = new Conexion();
        Connection cn = null;
        try {
            cn = cx.getConnection();
            cn.setAutoCommit(false);

            // Verificar propiedad y que el evento sea futuro (bloquea fila)
            String chk =
                "SELECT t.id FROM tickets t " +
                "JOIN events e ON e.id=t.event_id " +
                "WHERE t.id=? AND t.user_id=? AND e.date_time>NOW() FOR UPDATE";
            try (PreparedStatement ps = cn.prepareStatement(chk)) {
                ps.setInt(1, ticketId);
                ps.setInt(2, fromUserId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (!rs.next()) { cn.rollback(); return false; }
                }
            }

            // Actualizar propietario
            try (PreparedStatement up = cn.prepareStatement(
                    "UPDATE tickets SET user_id=?, transfer_at=NOW() WHERE id=?")) {
                up.setInt(1, toUserId);
                up.setInt(2, ticketId);
                if (up.executeUpdate() == 0) { cn.rollback(); return false; }
            }

            // Log
            try (PreparedStatement ins = cn.prepareStatement(
                    "INSERT INTO ticket_transfers(ticket_id, from_user_id, to_user_id, transfer_at) VALUES(?,?,?,NOW())")) {
                ins.setInt(1, ticketId);
                ins.setInt(2, fromUserId);
                ins.setInt(3, toUserId);
                ins.executeUpdate();
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
    // Crear un ticket (uso opcional)
    // ========================
    public int createOne(Connection cn, int userId, int eventId, String seat, String qrCode) throws SQLException {
        String sql = "INSERT INTO tickets(user_id, event_id, purchase_at, seat, qr_code) VALUES (?, ?, NOW(), ?, ?)";
        try (PreparedStatement ps = cn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, userId);
            ps.setInt(2, eventId);
            ps.setString(3, seat);
            ps.setString(4, qrCode);
            ps.executeUpdate();
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) return rs.getInt(1);
            }
        }
        return 0;
    }
}

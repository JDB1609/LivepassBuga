package dao;

import utils.Conexion;
import utils.Event;

import java.sql.*;
import java.util.*;
import java.math.BigDecimal;

public class EventDAO {

    // ==========================
    // SELECT BASE CON AGREGADOS
    // ==========================
    private static final String BASE_SELECT = """
        SELECT
            e.id,
            e.organizer_id,
            e.title,
            e.venue,
            e.genre,
            e.city,
            e.categories      AS category,
            e.type_events     AS event_type,
            e.text_acces      AS image_alt,
            e.date_time,
            e.description,
            e.image,
            e.status,

            COALESCE(SUM(tt.capacity), 0)  AS capacity_total,
            COALESCE(SUM(t.qty), 0)        AS sold_total,
            COALESCE(MIN(tt.price), 0)     AS base_price

        FROM events e
        LEFT JOIN ticket_types tt ON tt.id_event = e.id
        LEFT JOIN tickets      t  ON t.event_id  = e.id
    """;

    // ==========================
    // MAPPER
    // ==========================
    private Event map(ResultSet rs) throws SQLException {
        Event e = new Event();

        e.setId(rs.getInt("id"));

        long org = rs.getLong("organizer_id");
        if (!rs.wasNull()) e.setOrganizerId(org);

        e.setTitle(rs.getString("title"));
        e.setVenue(rs.getString("venue"));
        e.setGenre(rs.getString("genre"));
        e.setCity(rs.getString("city"));
        e.setCategories(rs.getString("category"));
        e.setEventType(rs.getString("event_type"));
        e.setImageAlt(rs.getString("image_alt"));

        Timestamp ts = rs.getTimestamp("date_time");
        if (ts != null) e.setDateTime(ts.toLocalDateTime());

        e.setCapacity(rs.getInt("capacity_total"));
        e.setSold(rs.getInt("sold_total"));
        e.setPrice(rs.getBigDecimal("base_price"));

        e.setDescription(rs.getString("description"));
        e.setImage(rs.getString("image"));
        e.setStatus(rs.getString("status"));   // setter convierte a enum internamente

        return e;
    }

    // ==========================
    // BIND DINÁMICO
    // ==========================
    private void bind(PreparedStatement ps, List<Object> params) throws SQLException {
        int i = 1;
        for (Object o : params) {
            if (o instanceof Integer)          ps.setInt(i++, (Integer) o);
            else if (o instanceof Long)        ps.setLong(i++, (Long) o);
            else if (o instanceof BigDecimal)  ps.setBigDecimal(i++, (BigDecimal) o);
            else                               ps.setObject(i++, o);
        }
    }

    // ==========================
    // STATUS JAVA (enum) → BD
    // ==========================
    private String toDbStatus(Event.Status st) {
        if (st == null) return "BORRADOR";

        switch (st) {
            case PUBLICADO:
                return "PUBLICADO";
            case FINALIZADO:
                return "REALIZADO";   // como definiste en la BD
            case PENDIENTE:
                return "PENDIENTE";
            default:
                return "BORRADOR";
        }
    }

    // ================= LISTADO ORGANIZADOR =================

    public List<Event> listByOrganizer(int organizerId, String q, String status) {

        StringBuilder sb = new StringBuilder(BASE_SELECT);
        sb.append(" WHERE e.organizer_id = ?");

        List<Object> params = new ArrayList<>();
        params.add(organizerId);

        sb.append(" GROUP BY e.id ORDER BY e.date_time DESC");

        List<Event> out = new ArrayList<>();

        try (Connection cn = new Conexion().getConnection();
             PreparedStatement ps = cn.prepareStatement(sb.toString())) {

            bind(ps, params);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    out.add(map(rs));
                }
            }

        } catch (Exception e) {
            throw new RuntimeException("Error listByOrganizer", e);
        }

        return out;
    }

    // =============== BUSCAR EVENTO POR ID + ORGANIZADOR =================

    public Optional<Event> findByIdAndOrganizer(int id, int organizerId) {
        StringBuilder sb = new StringBuilder(BASE_SELECT);
        sb.append(" WHERE e.id = ? AND e.organizer_id = ? ");
        sb.append(" GROUP BY e.id ");

        try (Connection cn = new Conexion().getConnection();
             PreparedStatement ps = cn.prepareStatement(sb.toString())) {

            ps.setInt(1, id);
            ps.setInt(2, organizerId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return Optional.of(map(rs));
                }
            }

        } catch (Exception e) {
            throw new RuntimeException("Error findByIdAndOrganizer", e);
        }

        return Optional.empty();
    }

    // ================= CREAR EVENTO =================

    public int create(Event e) {

        String sql = """
            INSERT INTO events(
                organizer_id,
                title,
                categories,
                genre,
                type_events,
                venue,
                city,
                date_time,
                status,
                description,
                image,
                text_acces
            )
            VALUES (?,?,?,?,?,?,?,?,?,?,?,?)
        """;

        try (Connection cn = new Conexion().getConnection();
             PreparedStatement ps = cn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setLong(1, e.getOrganizerId());
            ps.setString(2, e.getTitle());
            ps.setString(3, e.getCategories());
            ps.setString(4, e.getGenre());
            ps.setString(5, e.getEventType());
            ps.setString(6, e.getVenue());
            ps.setString(7, e.getCity());

            if (e.getDateTime() != null) {
                ps.setTimestamp(8, Timestamp.valueOf(e.getDateTime()));
            } else {
                ps.setNull(8, Types.TIMESTAMP);
            }

            ps.setString(9, toDbStatus(e.getStatus()));
            ps.setString(10, e.getDescription());
            ps.setString(11, e.getImage());
            ps.setString(12, e.getImageAlt()); // text_acces

            ps.executeUpdate();

            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) return rs.getInt(1);
            }

        } catch (Exception ex) {
            ex.printStackTrace();
            throw new RuntimeException("Error create Event", ex);
        }

        return 0;
    }

    // ================= ZONAS / AFOROS =================

    public void insertZone(int eventId, String name, int capacity, BigDecimal price) {

        String sql = """
            INSERT INTO ticket_types (name, id_event, capacity, price)
            VALUES (?,?,?,?)
        """;

        try (Connection cn = new Conexion().getConnection();
             PreparedStatement ps = cn.prepareStatement(sql)) {

            ps.setString(1, name);
            ps.setInt(2, eventId);
            ps.setInt(3, capacity);

            long priceValue = 0L;
            if (price != null) {
                priceValue = price.longValue();   // tu columna es BIGINT
            }
            ps.setLong(4, priceValue);

            System.out.println("[insertZone] eventId=" + eventId +
                    ", name=" + name +
                    ", cap=" + capacity +
                    ", price=" + priceValue);

            ps.executeUpdate();

        } catch (Exception e) {
            e.printStackTrace();
            throw new RuntimeException("Error insertZone", e);
        }
    }
    // ================= ACTUALIZAR EVENTO =================

    public void update(Event e, int organizerId) {

        String sql = """
            UPDATE events
            SET
                title       = ?,
                categories  = ?,
                genre       = ?,
                type_events = ?,
                venue       = ?,
                city        = ?,
                date_time   = ?,
                status      = ?,
                description = ?,
                image       = ?,
                text_acces  = ?
            WHERE id = ? AND organizer_id = ?
        """;

        try (Connection cn = new Conexion().getConnection();
             PreparedStatement ps = cn.prepareStatement(sql)) {

            ps.setString(1,  e.getTitle());
            ps.setString(2,  e.getCategories());
            ps.setString(3,  e.getGenre());
            ps.setString(4,  e.getEventType());
            ps.setString(5,  e.getVenue());
            ps.setString(6,  e.getCity());

            if (e.getDateTime() != null) {
                ps.setTimestamp(7, Timestamp.valueOf(e.getDateTime()));
            } else {
                ps.setNull(7, Types.TIMESTAMP);
            }

            ps.setString(8,  toDbStatus(e.getStatus()));
            ps.setString(9,  e.getDescription());
            ps.setString(10, e.getImage());
            ps.setString(11, e.getImageAlt());

            ps.setInt(12, e.getId());
            ps.setInt(13, organizerId);

            int rows = ps.executeUpdate();
            if (rows == 0) {
                throw new RuntimeException(
                    "No se actualizó ningún evento (id=" + e.getId() +
                    ", organizer=" + organizerId + ")"
                );
            }

        } catch (Exception ex) {
            throw new RuntimeException("Error update Event", ex);
        }
    }

    // ================= ELIMINAR EVENTO =================

    public boolean delete(int eventId, int organizerId) {

        String sql = "DELETE FROM events WHERE id = ? AND organizer_id = ?";

        try (Connection cn = new Conexion().getConnection();
             PreparedStatement ps = cn.prepareStatement(sql)) {

            ps.setInt(1, eventId);
            ps.setInt(2, organizerId);

            int rows = ps.executeUpdate();

            if (rows == 0) {
                System.out.println("[EventDAO.delete] No se encontró evento " +
                                   eventId + " para organizer " + organizerId);
                return false;
            }

            System.out.println("[EventDAO.delete] Evento " + eventId +
                               " borrado por organizer " + organizerId);
            return true;

        } catch (Exception e) {
            e.printStackTrace();
            throw new RuntimeException("Error delete Event", e);
        }
    }
    
    // =============== LISTADO PARA HOME / CARRUSEL =================

/**
 * Lista eventos PUBLICADOS para mostrar en el home (carrusel).
 * Ordenados por más vendidos y fecha más próxima.
 */
    public List<Event> listFeatured(int limit) {

        StringBuilder sb = new StringBuilder(BASE_SELECT);
        sb.append(" WHERE e.status = 'PUBLICADO' ");
        sb.append(" GROUP BY e.id ");
        sb.append(" ORDER BY sold_total DESC, e.date_time ASC ");

        if (limit > 0) {
            sb.append(" LIMIT ? ");
        }

        List<Event> out = new ArrayList<>();

        try (Connection cn = new Conexion().getConnection();
             PreparedStatement ps = cn.prepareStatement(sb.toString())) {

            if (limit > 0) {
                ps.setInt(1, limit);
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    out.add(map(rs));
                }
            }

        } catch (Exception e) {
            throw new RuntimeException("Error listFeatured", e);
        }

        return out;
    }


        // =============== LISTADO PARA HOME / POPULARES =================

    /**
     * Lista eventos PUBLICADOS para el home (carrusel "Popular esta semana").
     * Orden: primero los más vendidos y luego por fecha más próxima.
     */
    public List<Event> listPopular(int limit) {

        StringBuilder sb = new StringBuilder(BASE_SELECT);
        sb.append(" WHERE e.status = ? ");          // solo PUBLICADO
        sb.append(" GROUP BY e.id ");
        sb.append(" ORDER BY sold_total DESC, e.date_time ASC ");
        if (limit > 0) {
            sb.append(" LIMIT ? ");
        }

        List<Object> params = new ArrayList<>();
        params.add("PUBLICADO");
        if (limit > 0) {
            params.add(limit);
        }

        List<Event> out = new ArrayList<>();

        try (Connection cn = new Conexion().getConnection();
             PreparedStatement ps = cn.prepareStatement(sb.toString())) {

            bind(ps, params);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    out.add(map(rs));
                }
            }

        } catch (Exception e) {
            throw new RuntimeException("Error listPopular", e);
        }

        return out;
    }

}

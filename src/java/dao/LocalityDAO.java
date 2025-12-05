package dao;

import utils.Conexion;
import utils.Locality;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.math.BigDecimal;

public class LocalityDAO {

    // ===========================
    // CONEXIÓN A BD (usa utils.Conexion)
    // ===========================
    private Connection getConnection() throws SQLException {
        return new Conexion().getConnection();
    }

    // ===========================
    // INSERTAR LOCALIDAD (ticket_types)
    // ===========================
    public int create(Locality loc) throws SQLException {
        String sql = "INSERT INTO ticket_types (name, id_event, capacity, price) " +
                     "VALUES (?, ?, ?, ?)";

        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setString(1, loc.getName());
            ps.setInt(2, loc.getEventId());
            ps.setInt(3, loc.getCapacity());

            BigDecimal price = loc.getPrice();
            if (price == null) {
                price = BigDecimal.ZERO;
            }

            // Columna BIGINT -> guardamos como long
            ps.setLong(4, price.longValue());

            System.out.println("[LocalityDAO] INSERT ticket_types => " +
                    "name=" + loc.getName() +
                    ", eventId=" + loc.getEventId() +
                    ", capacity=" + loc.getCapacity() +
                    ", price=" + price);

            int affected = ps.executeUpdate();

            if (affected == 0) {
                throw new SQLException("No se pudo insertar la localidad, filas afectadas = 0");
            }

            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    int generatedId = rs.getInt(1);
                    loc.setId(generatedId);
                    return generatedId;
                } else {
                    throw new SQLException("No se obtuvo el ID generado para la localidad");
                }
            }
        }
    }

    // ===========================
    // OBTENER LOCALIDADES POR EVENTO
    // ===========================
    public List<Locality> findByEvent(int eventId) throws SQLException {
        List<Locality> list = new ArrayList<>();

        String sql = "SELECT id, name, id_event, capacity, price " +
                     "FROM ticket_types " +
                     "WHERE id_event = ? " +
                     "ORDER BY id";

        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, eventId);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Locality loc = new Locality();
                    loc.setId(rs.getInt("id"));
                    loc.setEventId(rs.getInt("id_event"));
                    loc.setName(rs.getString("name"));
                    loc.setCapacity(rs.getInt("capacity"));

                    long priceLong = rs.getLong("price");
                    loc.setPrice(BigDecimal.valueOf(priceLong));

                    list.add(loc);
                }
            }
        }

        return list;
    }

    // ===========================
    // BORRAR LOCALIDADES DE UN EVENTO
    // ===========================
    public int deleteByEvent(int eventId) throws SQLException {
        String sql = "DELETE FROM ticket_types WHERE id_event = ?";

        try (Connection con = getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, eventId);
            return ps.executeUpdate(); // número de filas borradas
        }
    }
}

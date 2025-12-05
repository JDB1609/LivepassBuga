package utils;

import java.io.Serializable;
import java.math.BigDecimal;

public class Locality implements Serializable {

    // Mapea a ticket_types.id
    private int id;

    // Mapea a ticket_types.id_event
    private int eventId;

    // Mapea a ticket_types.name
    private String name;

    // Mapea a ticket_types.capacity
    private int capacity;

    // Mapea a ticket_types.price (BIGINT)
    // Lo manejamos como BigDecimal en Java
    private BigDecimal price;

    public Locality() {
        this.price = BigDecimal.ZERO;
    }

    public Locality(int id, int eventId, String name, int capacity, BigDecimal price) {
        this.id = id;
        this.eventId = eventId;
        this.name = name;
        this.capacity = capacity;
        this.price = (price != null) ? price : BigDecimal.ZERO;
    }

    // ===== Getters & Setters =====

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getEventId() {
        return eventId;
    }

    public void setEventId(int eventId) {
        this.eventId = eventId;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public int getCapacity() {
        return capacity;
    }

    public void setCapacity(int capacity) {
        this.capacity = capacity;
    }

    public BigDecimal getPrice() {
        return price;
    }

    public void setPrice(BigDecimal price) {
        this.price = (price != null) ? price : BigDecimal.ZERO;
    }

    @Override
    public String toString() {
        return "Locality{" +
                "id=" + id +
                ", eventId=" + eventId +
                ", name='" + name + '\'' +
                ", capacity=" + capacity +
                ", price=" + price +
                '}';
    }
}

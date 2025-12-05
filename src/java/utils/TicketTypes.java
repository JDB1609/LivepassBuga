package utils;

import java.io.Serializable;

/**
 * Modelo TicketTypes mapeado exactamente a la tabla ticket_types
 */
public class TicketTypes implements Serializable {

    // ====== COLUMNAS DE LA TABLA ======
    private int id;
    private String name;
    private int id_event;   // FK -> events(id)
    private int capacity;
    private long price;

    // ====== CONSTRUCTOR VACÍO ======
    public TicketTypes() {
    }

    // ====== CONSTRUCTOR COMPLETO ======
    public TicketTypes(int id, String name, int id_event, int capacity, long price) {
        this.id = id;
        this.name = name;
        this.id_event = id_event;
        this.capacity = capacity;
        this.price = price;
    }

    // ====== GETTERS ======
    public int getId() {
        return id;
    }

    public String getName() {
        return name;
    }

    public int getId_event() {
        return id_event;
    }

    public int getCapacity() {
        return capacity;
    }

    public long getPrice() {
        return price;
    }

    // ====== SETTERS ======
    public void setId(int id) {
        this.id = id;
    }

    public void setName(String name) {
        this.name = name;
    }

    public void setId_event(int id_event) {
        this.id_event = id_event;
    }

    public void setCapacity(int capacity) {
        this.capacity = capacity;
    }

    public void setPrice(long price) {
        this.price = price;
    }

    // ====== TO STRING ======
    @Override
    public String toString() {
        return "TicketTypes{" +
                "id=" + id +
                ", name='" + name + '\'' +
                ", id_event=" + id_event +
                ", capacity=" + capacity +
                ", price=" + price +
                '}';
    }
}
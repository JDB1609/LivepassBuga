package utils;

public class ChartPoint {

    private String label;
    private int value;

    public ChartPoint(String label, int value) {
        this.label = label;
        this.value = value;
    }

    public String getLabel() { return label; }
    public int getValue() { return value; }

    public void setLabel(String label) { this.label = label; }
    public void setValue(int value) { this.value = value; }
}
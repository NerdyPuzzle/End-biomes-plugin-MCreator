package net.nerdypuzzle.endbiomes.elements;

import net.mcreator.element.GeneratableElement;
import net.mcreator.workspace.elements.ModElement;

public class EndBiome extends GeneratableElement {
    public String biome;
    public String generationType;
    public Number weight;
    public String midlands;
    public String barrens;
    public Number midlandsWeight;
    public Number barrensWeight;

    public EndBiome(ModElement element) {
        super(element);
    }

}

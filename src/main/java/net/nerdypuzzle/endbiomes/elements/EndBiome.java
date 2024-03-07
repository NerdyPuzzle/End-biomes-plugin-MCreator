package net.nerdypuzzle.endbiomes.elements;

import net.mcreator.element.GeneratableElement;
import net.mcreator.workspace.elements.ModElement;

import java.util.ArrayList;
import java.util.List;

public class EndBiome extends GeneratableElement {
    public String biome;
    public String generationType;
    public Number weight;
    public String midlands;
    public String barrens;

    public List<String> mixins = List.of("BiomeSourceMixin", "TheEndBiomeSourceMixin", "ClimateSamplerMixin", "NoiseConfigMixin", "ChunkNoiseSamplerMixin", "NoiseGeneratorSettingsAccess");
    public EndBiome(ModElement element) {
        super(element);
    }

}

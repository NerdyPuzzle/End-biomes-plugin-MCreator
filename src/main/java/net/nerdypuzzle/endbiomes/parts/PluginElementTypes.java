package net.nerdypuzzle.endbiomes.parts;

import net.mcreator.element.BaseType;
import net.mcreator.element.ModElementType;
import net.nerdypuzzle.endbiomes.elements.EndBiome;
import net.nerdypuzzle.endbiomes.elements.EndBiomeGUI;
import net.nerdypuzzle.endbiomes.elements.Endstone;
import net.nerdypuzzle.endbiomes.elements.EndstoneGUI;

import static net.mcreator.element.ModElementTypeLoader.register;

public class PluginElementTypes {
    public static ModElementType<?> ENDBIOME;
    public static ModElementType<?> ENDSTONE;

    public static void load() {

        ENDBIOME = register(
                new ModElementType<>("endbiome", (Character) 'E', BaseType.OTHER, EndBiomeGUI::new, EndBiome.class)
        );

        ENDSTONE = register(
                new ModElementType<>("endstone", (Character) null, BaseType.OTHER, EndstoneGUI::new, Endstone.class)
        );

    }

}

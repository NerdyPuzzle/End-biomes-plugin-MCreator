package net.nerdypuzzle.endbiomes;

import net.mcreator.plugin.JavaPlugin;
import net.mcreator.plugin.Plugin;
import net.mcreator.plugin.events.PreGeneratorsLoadingEvent;
import net.mcreator.plugin.events.ui.ModElementGUIEvent;
import net.mcreator.ui.component.JMinMaxSpinner;
import net.mcreator.ui.minecraft.MCItemHolder;
import net.mcreator.ui.modgui.BiomeGUI;
import net.mcreator.ui.modgui.ModElementGUI;
import net.nerdypuzzle.endbiomes.elements.EndBiomeGUI;
import net.nerdypuzzle.endbiomes.parts.PluginElementTypes;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import javax.swing.*;
import java.lang.reflect.Field;

public class Launcher extends JavaPlugin {

	private static final Logger LOG = LogManager.getLogger("End biomes");

	public static void disableComponent(ModElementGUI gui, Field field) throws Exception {
		field.setAccessible(true);
		((JComponent)field.get(gui)).setEnabled(false);
	}

	public Launcher(Plugin plugin) {
		super(plugin);

		addListener(PreGeneratorsLoadingEvent.class, event -> PluginElementTypes.load());
		addListener(ModElementGUIEvent.BeforeLoading.class, event -> {
			if (event.getModElementGUI() instanceof BiomeGUI biome) {
				if (EndBiomeGUI.isEndBiome(biome.getElementFromGUI().getModElement().getName(), null, event.getMCreator())) {
					try {
						disableComponent(biome, BiomeGUI.class.getDeclaredField("spawnBiome"));
						disableComponent(biome, BiomeGUI.class.getDeclaredField("spawnBiomeNether"));
						disableComponent(biome, BiomeGUI.class.getDeclaredField("spawnInCaves"));
						disableComponent(biome, BiomeGUI.class.getDeclaredField("underwaterBlock"));
						disableComponent(biome, BiomeGUI.class.getDeclaredField("genTemperature"));
						disableComponent(biome, BiomeGUI.class.getDeclaredField("genHumidity"));
						disableComponent(biome, BiomeGUI.class.getDeclaredField("genContinentalness"));
						disableComponent(biome, BiomeGUI.class.getDeclaredField("genErosion"));
						disableComponent(biome, BiomeGUI.class.getDeclaredField("genWeirdness"));
						disableComponent(biome, BiomeGUI.class.getDeclaredField("treesPerChunk"));
					} catch (Exception e) {
						e.printStackTrace();
					}
				}
			}
		});

		LOG.info("End biomes plugin was loaded");
	}

}
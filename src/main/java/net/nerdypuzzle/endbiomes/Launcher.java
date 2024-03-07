package net.nerdypuzzle.endbiomes;

import net.mcreator.plugin.JavaPlugin;
import net.mcreator.plugin.Plugin;
import net.mcreator.plugin.events.PreGeneratorsLoadingEvent;
import net.mcreator.plugin.events.ui.ModElementGUIEvent;
import net.mcreator.ui.component.JMinMaxSpinner;
import net.mcreator.ui.minecraft.MCItemHolder;
import net.mcreator.ui.modgui.BiomeGUI;
import net.nerdypuzzle.endbiomes.elements.EndBiomeGUI;
import net.nerdypuzzle.endbiomes.parts.PluginElementTypes;
import org.apache.logging.log4j.LogManager;
import org.apache.logging.log4j.Logger;

import javax.swing.*;
import java.lang.reflect.Field;

public class Launcher extends JavaPlugin {

	private static final Logger LOG = LogManager.getLogger("End biomes");

	public Launcher(Plugin plugin) {
		super(plugin);

		addListener(PreGeneratorsLoadingEvent.class, event -> PluginElementTypes.load());
		addListener(ModElementGUIEvent.BeforeLoading.class, event -> {
			if (event.getModElementGUI() instanceof BiomeGUI biome) {
				if (EndBiomeGUI.isEndBiome(biome.getElementFromGUI().name, null, event.getMCreator())) {
					try {
						Field field = BiomeGUI.class.getDeclaredField("spawnBiome");
						field.setAccessible(true);
						((JCheckBox)field.get(biome)).setEnabled(false);
						Field field1 = BiomeGUI.class.getDeclaredField("spawnBiomeNether");
						field1.setAccessible(true);
						((JCheckBox)field1.get(biome)).setEnabled(false);
						Field field2 = BiomeGUI.class.getDeclaredField("spawnInCaves");
						field2.setAccessible(true);
						((JCheckBox)field2.get(biome)).setEnabled(false);

						Field field3 = BiomeGUI.class.getDeclaredField("underwaterBlock");
						field3.setAccessible(true);
						((MCItemHolder)field3.get(biome)).setEnabled(false);

						Field field4 = BiomeGUI.class.getDeclaredField("genTemperature");
						field4.setAccessible(true);
						((JMinMaxSpinner)field4.get(biome)).setEnabled(false);
						Field field5 = BiomeGUI.class.getDeclaredField("genHumidity");
						field5.setAccessible(true);
						((JMinMaxSpinner)field5.get(biome)).setEnabled(false);
						Field field6 = BiomeGUI.class.getDeclaredField("genContinentalness");
						field6.setAccessible(true);
						((JMinMaxSpinner)field6.get(biome)).setEnabled(false);
						Field field7 = BiomeGUI.class.getDeclaredField("genErosion");
						field7.setAccessible(true);
						((JMinMaxSpinner)field7.get(biome)).setEnabled(false);
						Field field8 = BiomeGUI.class.getDeclaredField("genWeirdness");
						field8.setAccessible(true);
						((JMinMaxSpinner)field8.get(biome)).setEnabled(false);

						Field field9 = BiomeGUI.class.getDeclaredField("treesPerChunk");
						field9.setAccessible(true);
						((JSpinner)field9.get(biome)).setEnabled(false);
					} catch (Exception e) {
						e.printStackTrace();
					}
				}
			}
		});

		LOG.info("End biomes plugin was loaded");
	}

}
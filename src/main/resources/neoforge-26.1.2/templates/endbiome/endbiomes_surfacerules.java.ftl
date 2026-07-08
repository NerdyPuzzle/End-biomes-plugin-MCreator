package ${package}.init;

<#include "../mcitems.ftl">

<#macro getSurfaceRules element>
	registerSurfaceRules(Identifier.parse("${modid}:${element.getModElement().getRegistryName()}"), noiseGeneratorSettings,
		${mappedBlockToBlockStateCode(element.groundBlock)}, ${mappedBlockToBlockStateCode(element.undergroundBlock)});
</#macro>

@EventBusSubscriber
public class ${JavaModName}SurfaceRules {

	@SubscribeEvent
	public static void init(ServerAboutToStartEvent event) {
		LevelStem levelStem = event.getServer().registryAccess().lookupOrThrow(Registries.LEVEL_STEM).getValue(LevelStem.END);
		ChunkGenerator chunkGenerator = levelStem.generator();
		boolean hasEndBiomes = chunkGenerator.getBiomeSource().possibleBiomes().stream().anyMatch(biomeHolder ->
			biomeHolder.unwrapKey().orElseThrow().identifier().getNamespace().equals("${modid}"));

		if (hasEndBiomes) {
			if (chunkGenerator instanceof NoiseBasedChunkGenerator generator) {
				NoiseGeneratorSettings noiseGeneratorSettings = null;

				try {
				    Field settingsField = NoiseBasedChunkGenerator.class.getDeclaredField("settings");
				    settingsField.setAccessible(true);
				    noiseGeneratorSettings = ((Holder<NoiseGeneratorSettings>) settingsField.get(generator)).value();
				} catch (Exception e) {
				    e.printStackTrace();
				}

				<#list endbiomes as biome>
					<@getSurfaceRules w.getWorkspace().getModElementByName(biome.biome).getGeneratableElement()/>

					<#if biome.generationType == "Highlands" && biome.midlands != "Vanilla" && biome.midlands != biome.biome>
						<@getSurfaceRules w.getWorkspace().getModElementByName(biome.midlands).getGeneratableElement()/>
					</#if>

					<#if biome.generationType == "Highlands" && biome.barrens != "Vanilla" && biome.barrens != biome.biome>
						<@getSurfaceRules w.getWorkspace().getModElementByName(biome.barrens).getGeneratableElement()/>
					</#if>
				</#list>
			}
		}
	}

	public static void registerSurfaceRules(Identifier biome, NoiseGeneratorSettings noiseGeneratorSettings, BlockState groundBlock, BlockState undergroundBlock) {
		((NoiseGeneratorSettingsAccess)(Object)noiseGeneratorSettings).addSurfaceRule(SurfaceRules.sequence(
		SurfaceRules.ifTrue(SurfaceRules.isBiome(ResourceKey.create(Registries.BIOME, biome)),
			SurfaceRules.sequence(
				SurfaceRules.ifTrue(SurfaceRules.ON_FLOOR, SurfaceRules.state(groundBlock)),
				SurfaceRules.ifTrue(SurfaceRules.UNDER_FLOOR, SurfaceRules.state(undergroundBlock))
				)
			),
			noiseGeneratorSettings.surfaceRule()));
	}

}
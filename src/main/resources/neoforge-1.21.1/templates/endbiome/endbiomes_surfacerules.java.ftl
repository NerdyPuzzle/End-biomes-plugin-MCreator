<#include "../mcitems.ftl">

<#assign surfaceBiomes = []>
<#list endbiomes as endbiome>
	<#list [endbiome.biome] + (endbiome.generationType == "Highlands")?then([endbiome.midlands, endbiome.barrens], []) as biome>
		<#if biome != "Vanilla" && !surfaceBiomes?seq_contains(biome)>
			<#assign surfaceBiomes += [biome]>
		</#if>
	</#list>
</#list>

package ${package}.init;

@EventBusSubscriber
public class ${JavaModName}SurfaceRules {

	@SubscribeEvent
	public static void init(ServerAboutToStartEvent event) {
		LevelStem levelStem = event.getServer().registryAccess().registryOrThrow(Registries.LEVEL_STEM).get(LevelStem.END);
		if (levelStem == null || !(levelStem.generator() instanceof NoiseBasedChunkGenerator generator))
			return;

		boolean hasEndBiomes = generator.getBiomeSource().possibleBiomes().stream()
				.anyMatch(biome -> biome.unwrapKey().map(key -> key.location().getNamespace().equals("${modid}")).orElse(false));
		if (!hasEndBiomes)
			return;

		NoiseGeneratorSettings noiseGeneratorSettings = generator.generatorSettings().value();
		<#list surfaceBiomes as biomeName>
			<#assign biome = w.getWorkspace().getModElementByName(biomeName).getGeneratableElement()>
		registerSurfaceRules(ResourceLocation.fromNamespaceAndPath("${modid}", "${biome.getModElement().getRegistryName()}"), noiseGeneratorSettings,
				${mappedBlockToBlockStateCode(biome.groundBlock)}, ${mappedBlockToBlockStateCode(biome.undergroundBlock)});
		</#list>
	}

	public static void registerSurfaceRules(ResourceLocation biome, NoiseGeneratorSettings noiseGeneratorSettings, BlockState groundBlock, BlockState undergroundBlock) {
		((NoiseGeneratorSettingsAccess) (Object) noiseGeneratorSettings).addSurfaceRule(SurfaceRules.sequence(
				SurfaceRules.ifTrue(SurfaceRules.isBiome(ResourceKey.create(Registries.BIOME, biome)),
						SurfaceRules.sequence(
								SurfaceRules.ifTrue(SurfaceRules.ON_FLOOR, SurfaceRules.state(groundBlock)),
								SurfaceRules.ifTrue(SurfaceRules.UNDER_FLOOR, SurfaceRules.state(undergroundBlock))
						)
				),
				noiseGeneratorSettings.surfaceRule()));
	}

}
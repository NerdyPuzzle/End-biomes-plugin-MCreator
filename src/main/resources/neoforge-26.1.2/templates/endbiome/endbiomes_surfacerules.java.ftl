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
		LevelStem levelStem = event.getServer().registryAccess().lookupOrThrow(Registries.LEVEL_STEM).getValue(LevelStem.END);
		if (levelStem == null || !(levelStem.generator() instanceof NoiseBasedChunkGenerator generator))
			return;

		boolean hasEndBiomes = generator.getBiomeSource().possibleBiomes().stream()
				.anyMatch(biome -> biome.unwrapKey().map(key -> key.identifier().getNamespace().equals("${modid}")).orElse(false));
		if (!hasEndBiomes)
			return;

		NoiseGeneratorSettings noiseGeneratorSettings = generator.generatorSettings().value();
		<#list surfaceBiomes as biomeName>
			<#assign biome = w.getWorkspace().getModElementByName(biomeName).getGeneratableElement()>
		registerSurfaceRules(Identifier.fromNamespaceAndPath("${modid}", "${biome.getModElement().getRegistryName()}"), noiseGeneratorSettings,
				${mappedBlockToBlockStateCode(biome.groundBlock)}, ${mappedBlockToBlockStateCode(biome.undergroundBlock)});
		</#list>
	}

	public static void registerSurfaceRules(Identifier biome, NoiseGeneratorSettings noiseGeneratorSettings, BlockState groundBlock, BlockState undergroundBlock) {
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
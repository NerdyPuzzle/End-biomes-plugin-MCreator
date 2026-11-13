package ${package}.mixin;

/** Hook that lets {@link TheEndBiomeSourceMixin} add custom biomes to {@link BiomeSource#possibleBiomes()}. */
@Mixin(BiomeSource.class)
public abstract class BiomeSourceMixin {

	@ModifyReturnValue(method = "possibleBiomes", at = @At("RETURN"))
	private Set<Holder<Biome>> modifyPossibleBiomes(Set<Holder<Biome>> biomes) {
		return modifyBiomeSet(biomes);
	}

	/** Overridden by {@link TheEndBiomeSourceMixin}. */
	protected Set<Holder<Biome>> modifyBiomeSet(Set<Holder<Biome>> biomes) {
		return biomes;
	}

}
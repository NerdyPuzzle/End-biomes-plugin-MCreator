package ${package}.mixin;

/**
 * Hook that lets {@link TheEndBiomeSourceMixin} add custom biomes to {@link BiomeSource#possibleBiomes()}.
 *
 * <p>{@code @ModifyReturnValue} chains with every other injector on {@code possibleBiomes}, including the
 * {@code @Redirect} used by mods generated with older versions of the End biomes plugin.</p>
 */
@Mixin(BiomeSource.class)
public abstract class BiomeSourceMixin {

	@ModifyReturnValue(method = "possibleBiomes", at = @At("RETURN"))
	private Set<Holder<Biome>> modifyPossibleBiomes(Set<Holder<Biome>> biomes) {
		return modifyBiomeSet(biomes);
	}

	/**
	 * Overridden by {@link TheEndBiomeSourceMixin}.
	 *
	 * <p>CROSS-MOD CONTRACT: every mod generated with this plugin adds this exact method to {@link BiomeSource}, so
	 * its name, visibility and signature must never change.</p>
	 */
	protected Set<Holder<Biome>> modifyBiomeSet(Set<Holder<Biome>> biomes) {
		return biomes;
	}

}
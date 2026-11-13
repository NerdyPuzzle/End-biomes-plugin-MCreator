package ${package}.mixin;

import com.google.common.base.Suppliers;
import org.spongepowered.asm.mixin.Mutable;
import org.spongepowered.asm.mixin.Unique;

import java.util.function.Supplier;

/**
 * Adds the weighted custom biomes of every installed mod made with the End biomes plugin to {@link TheEndBiomeSource}.
 *
 * <p>Each of those mods ships its own copy of this mixin. They cooperate through the shared fields below and through
 * {@link EndBiomesInterop}, so every injector here only <em>adds</em> to vanilla behaviour and never cancels it.</p>
 */
@Mixin(TheEndBiomeSource.class)
public class TheEndBiomeSourceMixin extends BiomeSourceMixin {

	/*
	 * Not @Unique: Mixin merges these fields with the same fields of the copies of this mixin in other mods, which is
	 * how the copies find each other.
	 *
	 * overrides       - one memoized TheEndBiomeData.Overrides per installed mod, entry 0 is the "primary" one that
	 *                   every mod picks biomes from.
	 * overridesMerged - set once the biomes of the other entries have been merged into entry 0.
	 */
	private List<Supplier<Object>> overrides = new ArrayList<>();
	private volatile boolean endbiomes$overridesMerged;

	@Shadow
	@Mutable
	@Final
	static MapCodec<TheEndBiomeSource> CODEC;

	/**
	 * Swaps the codec for one that goes through {@link TheEndBiomeSource#create}, so the full biome registry can be
	 * captured instead of only the five vanilla biomes.
	 */
	@Inject(method = "<clinit>", at = @At("TAIL"))
	private static void modifyCodec(CallbackInfo ci) {
		CODEC = RecordCodecBuilder.mapCodec(instance -> instance.group(RegistryOps.retrieveGetter(Registries.BIOME))
				.apply(instance, instance.stable(TheEndBiomeSource::create)));
	}

	/** Captures the biome registry so the constructor below can resolve custom biomes. */
	@Inject(method = "create", at = @At("HEAD"))
	private static void rememberLookup(HolderGetter<Biome> biomes, CallbackInfoReturnable<?> cir) {
		TheEndBiomeData.biomeRegistry.set(biomes);
	}

	@Inject(method = "create", at = @At("TAIL"))
	private static void clearLookup(CallbackInfoReturnable<?> cir) {
		TheEndBiomeData.biomeRegistry.remove();
	}

	@Inject(method = "<init>", at = @At("RETURN"))
	private void init(CallbackInfo ci) {
		HolderGetter<Biome> biomes = TheEndBiomeData.biomeRegistry.get();
		if (biomes == null) {
			// Built without going through TheEndBiomeSource.create (e.g. by another mod): leave this source vanilla
			EndBiomesInterop.LOGGER.error("TheEndBiomeSource was created without the biome registry, custom end biomes of ${modid} will not generate in it");
			return;
		}

		overrides.add(Suppliers.memoize(() -> (Object) TheEndBiomeData.createOverrides(biomes)));
	}

	@ModifyReturnValue(method = "getNoiseBiome", at = @At("RETURN"))
	private Holder<Biome> getWeightedEndBiome(Holder<Biome> biome,
			@Local(argsOnly = true, ordinal = 0) int biomeX, @Local(argsOnly = true, ordinal = 1) int biomeY,
			@Local(argsOnly = true, ordinal = 2) int biomeZ, @Local(argsOnly = true) Climate.Sampler noise) {
		mergeOverrides();
		return EndBiomesInterop.pick(overrides, biomeX, biomeY, biomeZ, noise, biome);
	}

	@Override
	protected Set<Holder<Biome>> modifyBiomeSet(Set<Holder<Biome>> biomes) {
		return EndBiomesInterop.withCustomBiomes(overrides, biomes);
	}

	/** Merges the biomes of every other mod into the primary overrides, once per biome source. */
	@Unique
	private void mergeOverrides() {
		if (!endbiomes$overridesMerged) {
			synchronized (overrides) {
				if (!endbiomes$overridesMerged) {
					EndBiomesInterop.mergeInto(overrides);
					endbiomes$overridesMerged = true;
				}
			}
		}
	}

}

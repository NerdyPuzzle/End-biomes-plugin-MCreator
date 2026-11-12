package ${package}.mixin;

import com.google.common.base.Preconditions;
import org.spongepowered.asm.mixin.Unique;

/**
 * Gives every {@link Climate.Sampler} the world seed and a noise used to pick weighted custom end biomes.
 *
 * <p>Every mod generated with the End biomes plugin adds the {@link SamplerHooks} methods to this class, Mixin keeps
 * the implementation of whichever mod is applied first. The fields are @Unique so each implementation keeps its own.</p>
 */
@Mixin(Climate.Sampler.class)
public class ClimateSamplerMixin implements SamplerHooks {
	@Unique
	private Long seed = null;

	@Unique
	private ImprovedNoise endBiomesSampler = null;

	@Override
	public void setSeed(long seed) {
		this.seed = seed;
	}

	@Override
	public long getSeed() {
		return this.seed;
	}

	@Override
	public ImprovedNoise getEndBiomesSampler() {
		if (endBiomesSampler == null) {
			Preconditions.checkState(seed != null, "MultiNoiseSampler doesn't have a seed set, created using different method?");
			endBiomesSampler = new ImprovedNoise(new WorldgenRandom(new LegacyRandomSource(seed)));
		}

		return endBiomesSampler;
	}

}
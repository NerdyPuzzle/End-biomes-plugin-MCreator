package ${package}.endbiomes;

/** Implemented on {@link Climate.Sampler} by {@code ClimateSamplerMixin}. */
public interface SamplerHooks {
	ImprovedNoise getEndBiomesSampler();

	void setSeed(long seed);

	long getSeed();
}
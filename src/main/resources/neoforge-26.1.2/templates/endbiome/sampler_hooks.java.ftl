package ${package}.endbiomes;

/**
 * Implemented on {@link Climate.Sampler} by {@code ClimateSamplerMixin}.
 *
 * <p>CROSS-MOD CONTRACT: every mod generated with the End biomes plugin adds these exact methods to
 * {@link Climate.Sampler} (through its own copy of this interface), so their names and signatures must never change.</p>
 */
public interface SamplerHooks {
	ImprovedNoise getEndBiomesSampler();

	void setSeed(long seed);

	long getSeed();
}
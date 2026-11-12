package ${package}.mixin;

import org.spongepowered.asm.mixin.gen.Accessor;
import org.spongepowered.asm.mixin.Mutable;

/**
 * Lets the generated SurfaceRules class add surface rules for its end biomes.
 *
 * <p>CROSS-MOD CONTRACT: every mod generated with the End biomes plugin declares this accessor, keep its name and
 * target unchanged so the copies keep overlapping instead of conflicting.</p>
 */
@Mixin(NoiseGeneratorSettings.class)
public interface NoiseGeneratorSettingsAccess {

	@Accessor("surfaceRule")
	@Mutable
	void addSurfaceRule(SurfaceRules.RuleSource ruleSource);

}
package ${package}.mixin;

import net.minecraft.world.level.levelgen.material.rule.MaterialRule;
import org.spongepowered.asm.mixin.Mutable;

/** Lets the generated SurfaceRules class add material rules for its end biomes. */
@Mixin(NoiseGeneratorSettings.class)
public interface NoiseGeneratorSettingsAccess {

	@Accessor("materialRule")
	@Mutable
	void endbiomes$setMaterialRule(Holder<MaterialRule> materialRule);

}
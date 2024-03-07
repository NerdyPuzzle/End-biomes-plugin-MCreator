package net.nerdypuzzle.endbiomes.elements;

import net.mcreator.element.ModElementType;
import net.mcreator.element.types.Biome;
import net.mcreator.generator.GeneratorFlavor;
import net.mcreator.plugin.PluginLoader;
import net.mcreator.ui.MCreator;
import net.mcreator.ui.component.SearchableComboBox;
import net.mcreator.ui.component.util.ComboBoxUtil;
import net.mcreator.ui.component.util.ComponentUtils;
import net.mcreator.ui.component.util.PanelUtils;
import net.mcreator.ui.help.HelpUtils;
import net.mcreator.ui.init.L10N;
import net.mcreator.ui.laf.themes.Theme;
import net.mcreator.ui.modgui.ModElementGUI;
import net.mcreator.ui.validation.AggregatedValidationResult;
import net.mcreator.ui.validation.ValidationGroup;
import net.mcreator.util.ListUtils;
import net.mcreator.workspace.elements.ModElement;
import net.nerdypuzzle.endbiomes.parts.PluginElementTypes;

import java.util.Collections;
import java.util.List;
import javax.swing.*;
import java.awt.*;
import java.util.stream.Collectors;

public class EndBiomeGUI extends ModElementGUI<EndBiome> {
    private final ValidationGroup page1group = new ValidationGroup();
    private final SearchableComboBox<String> biome;
    private final JComboBox<String> generationType;
    private final JSpinner weight;
    private final SearchableComboBox<String> midlands;
    private final SearchableComboBox<String> barrens;

    public EndBiomeGUI(MCreator mcreator, ModElement modElement, boolean editingMode) {
        super(mcreator, modElement, editingMode);
        biome = new SearchableComboBox<>();
        generationType = new JComboBox<>(new String[]{ "Highlands", "Small islands", "Main island", "Midlands", "Barrens" });
        weight = new JSpinner(new SpinnerNumberModel(1, 0.1, 1000, 0.1));
        midlands = new SearchableComboBox<>();
        barrens = new SearchableComboBox<>();
        this.initGUI();
        super.finalizeGUI();
    }

    protected void initGUI() {
        biome.setPreferredSize(new Dimension(300, 35));
        midlands.setPreferredSize(new Dimension(300, 35));
        ComponentUtils.deriveFont(biome, 16F);
        ComponentUtils.deriveFont(generationType, 16F);
        ComponentUtils.deriveFont(midlands, 16F);
        ComponentUtils.deriveFont(barrens, 16F);

        JPanel pane1 = new JPanel(new BorderLayout());
        pane1.setOpaque(false);

        JPanel mainPanel = new JPanel(new GridLayout(3, 2, 0, 2));
        mainPanel.setOpaque(false);
        mainPanel.add(HelpUtils.wrapWithHelpButton(this.withEntry("endbiome/biome"), L10N.label("elementgui.endbiome.biome", new Object[0])));
        mainPanel.add(biome);
        mainPanel.add(HelpUtils.wrapWithHelpButton(this.withEntry("endbiome/generation"), L10N.label("elementgui.endbiome.generation", new Object[0])));
        mainPanel.add(generationType);
        mainPanel.add(HelpUtils.wrapWithHelpButton(this.withEntry("endbiome/weight"), L10N.label("elementgui.endbiome.weight", new Object[0])));
        mainPanel.add(weight);
        mainPanel.setBorder(BorderFactory.createTitledBorder(BorderFactory.createLineBorder(Theme.current().getForegroundColor(), 1), L10N.t("elementgui.endbiome.props_border", new Object[0]), 4, 0, this.getFont(), Theme.current().getForegroundColor()));

        JPanel subBiomes = new JPanel(new GridLayout(2, 2, 0, 2));
        subBiomes.setOpaque(false);
        subBiomes.add(HelpUtils.wrapWithHelpButton(this.withEntry("endbiome/midlands"), L10N.label("elementgui.endbiome.midlands", new Object[0])));
        subBiomes.add(midlands);
        subBiomes.add(HelpUtils.wrapWithHelpButton(this.withEntry("endbiome/barrens"), L10N.label("elementgui.endbiome.barrens", new Object[0])));
        subBiomes.add(barrens);
        subBiomes.setBorder(BorderFactory.createTitledBorder(BorderFactory.createLineBorder(Theme.current().getForegroundColor(), 1), L10N.t("elementgui.endbiome.subbiomes_border", new Object[0]), 4, 0, this.getFont(), Theme.current().getForegroundColor()));

        generationType.addActionListener((e) -> {
            midlands.setEnabled(generationType.getSelectedItem().equals("Highlands"));
            barrens.setEnabled(generationType.getSelectedItem().equals("Highlands"));
        });

        JPanel topnbottom = new JPanel(new BorderLayout());
        topnbottom.setOpaque(false);
        topnbottom.add(PanelUtils.northAndCenterElement(mainPanel, subBiomes));

        pane1.add(PanelUtils.totalCenterInPanel(topnbottom));
        addPage(pane1);
    }

    public void reloadDataLists() {
        super.reloadDataLists();
        ComboBoxUtil.updateComboBoxContents(biome, this.mcreator.getWorkspace().getModElements().stream().filter((var) -> {
            return var.getType() == ModElementType.BIOME;
        }).map(ModElement::getName).collect(Collectors.toList()));
        ComboBoxUtil.updateComboBoxContents(midlands, ListUtils.merge(Collections.singleton("Vanilla"), this.mcreator.getWorkspace().getModElements().stream().filter((var) -> {
            return var.getType() == ModElementType.BIOME && (biome.getSelectedItem() == null || var != mcreator.getWorkspace().getModElementByName(biome.getSelectedItem()));
        }).map(ModElement::getName).collect(Collectors.toList())), "Vanilla");
        ComboBoxUtil.updateComboBoxContents(barrens, ListUtils.merge(Collections.singleton("Vanilla"), this.mcreator.getWorkspace().getModElements().stream().filter((var) -> {
            return var.getType() == ModElementType.BIOME && (biome.getSelectedItem() == null || var != mcreator.getWorkspace().getModElementByName(biome.getSelectedItem()));
        }).map(ModElement::getName).collect(Collectors.toList())), "Vanilla");
    }

    public static boolean isEndBiome(String biome, ModElement endbiome, MCreator mcreator) {
        List<EndBiome> endBiomes = mcreator.getWorkspace().getModElements().stream().filter((var) -> {
            return var.getType() == PluginElementTypes.ENDBIOME && var != endbiome;
        }).map(end -> ((EndBiome)end.getGeneratableElement())).collect(Collectors.toList());
        for (EndBiome end : endBiomes)
            if (end.biome.equals(biome) || end.midlands.equals(biome) || end.barrens.equals(biome))
                return true;
        return false;
    }

    protected AggregatedValidationResult validatePage(int page) {
        if (PluginLoader.INSTANCE.getPlugins().stream().filter((plugin) -> { return plugin.getID().equals("forge_mixins"); }).toList().isEmpty() && mcreator.getGenerator().getGeneratorConfiguration().getGeneratorFlavor() != GeneratorFlavor.FABRIC)
            return new AggregatedValidationResult.FAIL(L10N.t("elementgui.endbiome.needs_mixins", new Object[0]));
        if (biome.getSelectedItem() == null)
            return new AggregatedValidationResult.FAIL(L10N.t("elementgui.endbiome.needs_biome", new Object[0]));
        if (!midlands.getSelectedItem().equals("Vanilla") && !barrens.getSelectedItem().equals("Vanilla") && midlands.getSelectedItem().equals(barrens.getSelectedItem()))
            return new AggregatedValidationResult.FAIL(L10N.t("elementgui.endbiome.same_subbiomes", new Object[0]));
        if (isEndBiome(biome.getSelectedItem(), getModElement(), mcreator))
            return new AggregatedValidationResult.FAIL(L10N.t("elementgui.endbiome.is_end", new Object[0]));
        return new AggregatedValidationResult(this.page1group);
    }

    protected void afterGeneratableElementStored() {
        Biome modified = (Biome) mcreator.getWorkspace().getModElementByName(biome.getSelectedItem()).getGeneratableElement();
        modified.spawnBiome = false;
        modified.spawnBiomeNether = false;
        modified.spawnInCaves = false;
    }

    public void openInEditingMode(EndBiome endbiome) {
        biome.setSelectedItem(endbiome.biome);
        generationType.setSelectedItem(endbiome.generationType);
        weight.setValue(endbiome.weight);
        midlands.setSelectedItem(endbiome.midlands);
        barrens.setSelectedItem(endbiome.barrens);
    }

    public EndBiome getElementFromGUI() {
        EndBiome endbiome = new EndBiome(this.modElement);
        endbiome.biome = biome.getSelectedItem();
        endbiome.generationType = (String) generationType.getSelectedItem();
        endbiome.weight = (Number) weight.getValue();
        endbiome.midlands = midlands.getSelectedItem();
        endbiome.barrens = barrens.getSelectedItem();
        return endbiome;
    }

}

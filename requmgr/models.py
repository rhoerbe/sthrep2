from django.db import models

class FeatureGroup(models.Model):
    id = models.AutoField(primary_key=True)
    fg_id = models.CharField('FGId', max_length=6, unique=True, null=False, blank=False, help_text="Mnemonic ID up to 6 characters")
    name = models.CharField(max_length=50, unique=True, null=False, blank=False)

    class Meta:
        ordering = ['name']

    def __unicode__(self):
        return self.name


class Feature(models.Model):
    id = models.AutoField(primary_key=True)
    f_id = models.CharField('FeatId', max_length=8, null=False, blank=False, help_text="Mnemonic ID up to 8 characters")
    name = models.CharField(max_length=50)
    featuregroup = models.ForeignKey('Featuregroup')

    class Meta:
        ordering = ['featuregroup', 'name']
        unique_together = ['featuregroup', 'name']
        unique_together = ['featuregroup', 'f_id']

    def __unicode__(self):
        return self.name

    # def get_model_perms(self, request):
    #     # Return empty perms dict thus hiding the model from admin index.
    #     return {}

        #TODO remove, replaced by __ lookup
        #def get_fg_id(self):
        #    return self.featuregroup.fg_id
        #get_fg_id.short_description = 'FeatGrp'


class Reference(models.Model):
    id = models.AutoField(primary_key=True)
    name = models.CharField(max_length=20, help_text='Short document reference, e.g. SAMLCore')
    version = models.CharField(max_length=20, help_text='Document version, e.g. 2.0-os')

    class Meta:
        db_table = 'reference'
        ordering = ['name', 'version']
        unique_together = ['name', 'version']

    def __unicode__(self):
        return self.name + ' (' + self.version + ')'


class Requirement(models.Model):
    id = models.AutoField(primary_key=True)
    name = models.CharField(max_length=250, help_text="concise yet complete description of requirement, up to 250 characters")
    feature = models.ForeignKey(Feature)
    operation_count = models.IntegerField(default=0)  # maintainer by Postgres Triggers as stored count (Operation) / set to readonly in forms
    reference = models.ForeignKey(Reference, null=True, blank=True, help_text='Reference to standard or profile document if the requirement can be tracked to it')
    reference_location = models.CharField(max_length=40, null=True, blank=True, help_text='Location within reference document, e.g. line 2952')

    class Meta:
        ordering = ['feature', 'name']
        unique_together = ['feature', 'name']

    def __unicode__(self):
        return self.feature.featuregroup.fg_id + '/' + self.feature.f_id + ' (R' + str(self.id) + ') ' + self.name
        #return 'R' + str(self.id) + ' ' + self.name

    # def get_f_id(self):
    #     return self.feature.f_id
    # get_f_id.short_description = 'FeatId'
    #
    # def get_fg_id(self):
    #     return self.feature.featuregroup.fg_id
    # get_fg_id.short_description = 'FeatGrp'



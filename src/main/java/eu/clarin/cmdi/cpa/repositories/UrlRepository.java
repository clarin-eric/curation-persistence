package eu.clarin.cmdi.cpa.repositories;

import org.springframework.data.repository.CrudRepository;
import org.springframework.lang.Nullable;
import org.springframework.stereotype.Repository;

import eu.clarin.cmdi.cpa.entities.Url;

@Repository
public interface UrlRepository extends CrudRepository<Url, Long> {
   
   @Nullable
   public Url findByUrl(String url);

}
